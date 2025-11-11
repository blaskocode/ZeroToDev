#!/bin/bash
# Deploy to AWS ECS
# This script builds Docker images, pushes them to ECR, and deploys to ECS via Terraform.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
AWS_REGION="us-east-1"
ENVIRONMENT="dev"
PROJECT_NAME="zero-to-dev"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploy to AWS ECS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed.${NC}"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites installed${NC}"
echo ""

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${BLUE}AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${BLUE}AWS Region: ${AWS_REGION}${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo ""

# ECR Repository URLs
API_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-api"
FRONTEND_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}-${ENVIRONMENT}-frontend"

# Image tags (using git commit SHA or timestamp)
if command -v git &> /dev/null && [ -d "${PROJECT_ROOT}/.git" ]; then
    IMAGE_TAG=$(git rev-parse --short HEAD)
else
    IMAGE_TAG=$(date +%s)
fi

echo -e "${BLUE}Image Tag: ${IMAGE_TAG}${NC}"
echo ""

# Login to ECR
echo -e "${YELLOW}Logging in to Amazon ECR...${NC}"
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
echo -e "${GREEN}✓ Logged in to ECR${NC}"
echo ""

# Build and push API image
echo -e "${YELLOW}Building API Docker image...${NC}"
cd "${PROJECT_ROOT}/api"
docker build -t "${API_REPO}:${IMAGE_TAG}" -t "${API_REPO}:latest" .
echo -e "${GREEN}✓ API image built${NC}"

echo -e "${YELLOW}Pushing API image to ECR...${NC}"
docker push "${API_REPO}:${IMAGE_TAG}"
docker push "${API_REPO}:latest"
echo -e "${GREEN}✓ API image pushed${NC}"
echo ""

# Get ALB URL for frontend build (if ALB exists)
cd "${PROJECT_ROOT}/infra/terraform"
ALB_URL=""
if [ -d ".terraform" ]; then
    terraform init -backend=false >/dev/null 2>&1 || true
    ALB_URL=$(terraform output -raw alb_url 2>/dev/null || echo "")
fi

# Use ALB URL if available, otherwise use placeholder (will be fixed on next deployment)
if [ -z "$ALB_URL" ] || [ "$ALB_URL" = "" ]; then
    ALB_URL="http://placeholder-alb-url"
    echo -e "${YELLOW}⚠ ALB URL not found, using placeholder (will be updated after deployment)${NC}"
else
    echo -e "${BLUE}Using ALB URL: ${ALB_URL}${NC}"
fi

# Build and push frontend image (production target)
echo -e "${YELLOW}Building Frontend Docker image...${NC}"
cd "${PROJECT_ROOT}/frontend"
docker build --target production \
    --build-arg VITE_API_URL="${ALB_URL}" \
    -t "${FRONTEND_REPO}:${IMAGE_TAG}" \
    -t "${FRONTEND_REPO}:latest" .
echo -e "${GREEN}✓ Frontend image built${NC}"

echo -e "${YELLOW}Pushing Frontend image to ECR...${NC}"
docker push "${FRONTEND_REPO}:${IMAGE_TAG}"
docker push "${FRONTEND_REPO}:latest"
echo -e "${GREEN}✓ Frontend image pushed${NC}"
echo ""

# Deploy with Terraform
echo -e "${YELLOW}Deploying infrastructure with Terraform...${NC}"
cd "${PROJECT_ROOT}/infra/terraform"

# Check if terraform.tfvars exists, create if not
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${YELLOW}Creating terraform.tfvars...${NC}"
    cat > terraform.tfvars <<EOF
# AWS Configuration
aws_region  = "${AWS_REGION}"
environment = "${ENVIRONMENT}"
project_name = "${PROJECT_NAME}"

# Docker Images
api_image      = "${API_REPO}:${IMAGE_TAG}"
frontend_image = "${FRONTEND_REPO}:${IMAGE_TAG}"

# Database Configuration (update these values)
db_username = "dbadmin"
db_password = "CHANGE_ME_PLEASE"
EOF
    echo -e "${RED}⚠ Please update terraform.tfvars with your database password!${NC}"
    echo -e "${YELLOW}Edit: ${PROJECT_ROOT}/infra/terraform/terraform.tfvars${NC}"
    read -p "Press Enter after updating the file..."
fi

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
fi

# Plan and apply
echo -e "${YELLOW}Planning infrastructure changes...${NC}"
terraform plan \
    -var="api_image=${API_REPO}:${IMAGE_TAG}" \
    -var="frontend_image=${FRONTEND_REPO}:${IMAGE_TAG}" \
    -out=tfplan

echo ""
echo -e "${YELLOW}Applying infrastructure changes...${NC}"
read -p "Apply these changes? (yes/no): " confirm
if [ "$confirm" = "yes" ]; then
    terraform apply tfplan
    rm -f tfplan
    echo -e "${GREEN}✓ Infrastructure deployed${NC}"
else
    echo -e "${YELLOW}Deployment cancelled${NC}"
    rm -f tfplan
    exit 0
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "N/A")
echo -e "${BLUE}Application URLs:${NC}"
echo -e "  • Frontend: ${GREEN}http://${ALB_DNS}${NC}"
echo -e "  • API: ${GREEN}http://${ALB_DNS}/api${NC}"
echo -e "  • API Health: ${GREEN}http://${ALB_DNS}/health${NC}"
echo ""
echo -e "${YELLOW}Note: It may take a few minutes for services to become healthy.${NC}"
echo ""

