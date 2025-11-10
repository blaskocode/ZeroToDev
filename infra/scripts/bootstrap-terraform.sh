#!/bin/bash
# Bootstrap Terraform Backend
# This script creates the S3 bucket and DynamoDB table required for Terraform state management.
# Run this ONCE before the first `terraform init`.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="zero-to-dev-terraform-state"
DYNAMODB_TABLE="zero-to-dev-terraform-locks"
AWS_REGION="us-east-1"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Terraform Backend Bootstrap${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials are not configured.${NC}"
    echo "Please run: aws configure"
    exit 1
fi

echo -e "${GREEN}✓ AWS CLI is installed and configured${NC}"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${BLUE}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${BLUE}AWS Region: ${AWS_REGION}${NC}"
echo ""

# Create S3 bucket for Terraform state
echo -e "${YELLOW}Creating S3 bucket: ${BUCKET_NAME}${NC}"
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo -e "${GREEN}✓ S3 bucket already exists${NC}"
else
    if [ "${AWS_REGION}" = "us-east-1" ]; then
        # us-east-1 doesn't require LocationConstraint
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${AWS_REGION}"
    else
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${AWS_REGION}" \
            --create-bucket-configuration LocationConstraint="${AWS_REGION}"
    fi
    echo -e "${GREEN}✓ S3 bucket created${NC}"
fi

# Enable versioning on the S3 bucket
echo -e "${YELLOW}Enabling versioning on S3 bucket${NC}"
aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled
echo -e "${GREEN}✓ Versioning enabled${NC}"

# Enable encryption on the S3 bucket
echo -e "${YELLOW}Enabling encryption on S3 bucket${NC}"
aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
echo -e "${GREEN}✓ Encryption enabled${NC}"

# Block public access
echo -e "${YELLOW}Blocking public access to S3 bucket${NC}"
aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
echo -e "${GREEN}✓ Public access blocked${NC}"

# Create DynamoDB table for state locking
echo -e "${YELLOW}Creating DynamoDB table: ${DYNAMODB_TABLE}${NC}"
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${AWS_REGION}" &> /dev/null; then
    echo -e "${GREEN}✓ DynamoDB table already exists${NC}"
else
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "${AWS_REGION}" \
        --tags Key=Project,Value=zero-to-dev Key=ManagedBy,Value=terraform
    
    echo -e "${YELLOW}Waiting for DynamoDB table to be active...${NC}"
    aws dynamodb wait table-exists --table-name "${DYNAMODB_TABLE}" --region "${AWS_REGION}"
    echo -e "${GREEN}✓ DynamoDB table created${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Bootstrap Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Resources created:${NC}"
echo -e "  • S3 Bucket: ${BUCKET_NAME}"
echo -e "  • DynamoDB Table: ${DYNAMODB_TABLE}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Run: ${GREEN}cd infra/terraform${NC}"
echo -e "  2. Run: ${GREEN}terraform init${NC}"
echo -e "  3. Run: ${GREEN}terraform plan${NC}"
echo ""

