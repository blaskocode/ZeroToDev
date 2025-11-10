# Terraform Backend Configuration
# This stores Terraform state in S3 with locking via DynamoDB
# Run the bootstrap script first: ./infra/scripts/bootstrap-terraform.sh

terraform {
  backend "s3" {
    bucket         = "zero-to-dev-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "zero-to-dev-terraform-locks"
    encrypt        = true

    # Uncomment after running bootstrap script
    # skip_credentials_validation = false
    # skip_metadata_api_check     = false
  }
}

