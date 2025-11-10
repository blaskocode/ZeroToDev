# Infrastructure Documentation

This directory contains all Infrastructure as Code (IaC) for deploying the Zero-to-Running Developer Environment to AWS.

## Overview

The infrastructure is managed using **Terraform** and deploys to **AWS** using:
- **ECS (Fargate)** for container orchestration
- **RDS PostgreSQL** for the database
- **ElastiCache Redis** for caching
- **Application Load Balancer (ALB)** for traffic routing
- **ECR** for Docker image storage

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
              ┌──────────────────────┐
              │ Application Load     │
              │ Balancer (ALB)       │
              └──────────┬───────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
   ┌─────────┐     ┌─────────┐     ┌─────────┐
   │  ECS    │     │  ECS    │     │  ECS    │
   │ Frontend│     │  API    │     │  API    │
   │  Task   │     │  Task   │     │  Task   │
   └─────────┘     └────┬────┘     └────┬────┘
                        │               │
         ┌──────────────┼───────────────┘
         ▼              ▼
   ┌──────────┐   ┌──────────┐
   │   RDS    │   │  Redis   │
   │PostgreSQL│   │ElastiCache│
   └──────────┘   └──────────┘
```

## Directory Structure

```
infra/
├── terraform/              # Terraform configurations
│   ├── main.tf            # Root module
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   ├── versions.tf        # Provider versions
│   ├── backend.tf         # S3 backend configuration
│   └── modules/           # Terraform modules
│       ├── networking/    # VPC, subnets, NAT, IGW
│       ├── ecr/          # Docker image repositories
│       ├── rds/          # PostgreSQL database
│       ├── elasticache/  # Redis cache
│       ├── alb/          # Application Load Balancer
│       └── ecs/          # ECS cluster and services
└── scripts/
    ├── bootstrap-terraform.sh  # One-time backend setup
    └── deploy.sh              # Build and deploy script
```

## Prerequisites

### Required Tools
- **AWS CLI** (>= 2.0)
- **Terraform** (>= 1.0)
- **Docker** (>= 24.0)
- **Git** (for image tagging)

### AWS Account Setup
1. Create an AWS account if you don't have one
2. Configure AWS CLI credentials:
   ```bash
   aws configure
   ```
3. Set the following:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., `us-east-1`)
   - Default output format (e.g., `json`)

### Required AWS Permissions
The AWS user/role needs the following permissions:
- **S3**: Full access (for Terraform state)
- **DynamoDB**: Full access (for state locking)
- **EC2**: VPC, Subnet, Security Group management
- **ECS**: Cluster, Service, Task Definition management
- **ECR**: Repository management
- **RDS**: Database instance management
- **ElastiCache**: Redis cluster management
- **ELB**: Application Load Balancer management
- **IAM**: Role and Policy management
- **CloudWatch**: Log group management

See `docs/github-actions-iam-policy.json` for a sample IAM policy.

## Cost Estimate

**Monthly costs (US East 1, dev environment):**

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| ECS Fargate | 2 tasks (0.25 vCPU, 0.5 GB) | ~$15/month |
| RDS PostgreSQL | db.t3.micro, 20GB | ~$15/month |
| ElastiCache Redis | cache.t3.micro | ~$12/month |
| Application Load Balancer | 1 ALB | ~$16/month |
| NAT Gateway | 1 NAT Gateway | ~$32/month |
| Data Transfer | Minimal usage | ~$5/month |
| **Total** | | **~$95/month** |

**Cost Reduction Tips:**
- Use Fargate Spot for non-production (50-70% savings)
- Use single AZ for dev/test environments
- Enable ECS auto-scaling to scale down during off-hours
- Consider using a bastion host instead of NAT Gateway for dev

## Deployment Guide

### Step 1: Bootstrap Terraform Backend (One-Time)

Before the first deployment, create the S3 bucket and DynamoDB table for Terraform state:

```bash
make aws-bootstrap
```

This script will:
- Create S3 bucket: `zero-to-dev-terraform-state`
- Enable versioning and encryption
- Block public access
- Create DynamoDB table: `zero-to-dev-terraform-locks`
- Configure state locking

### Step 2: Configure Variables

Create or update `infra/terraform/terraform.tfvars`:

```hcl
# AWS Configuration
aws_region   = "us-east-1"
environment  = "dev"
project_name = "zero-to-dev"

# Database Configuration (CHANGE THESE!)
db_username = "dbadmin"
db_password = "YourSecurePasswordHere123!"

# Optional: Override defaults
# db_instance_class = "db.t3.small"
# redis_node_type   = "cache.t3.small"
```

**⚠️ Important:** Never commit `terraform.tfvars` to git! It's already in `.gitignore`.

### Step 3: Plan Infrastructure

Review what will be created:

```bash
make aws-plan
```

This will show all resources Terraform will create.

### Step 4: Deploy to AWS

Build Docker images, push to ECR, and deploy infrastructure:

```bash
make aws-deploy
```

This script will:
1. Build API Docker image
2. Build Frontend Docker image (production target)
3. Push images to ECR
4. Run `terraform apply`
5. Output the ALB DNS name

**First deployment takes ~10-15 minutes** as AWS provisions:
- VPC and networking resources
- RDS instance
- ElastiCache cluster
- ECS cluster and services
- Application Load Balancer

### Step 5: Verify Deployment

After deployment completes, test the endpoints:

```bash
# Get the ALB DNS name
make aws-outputs

# Test the API health endpoint
curl http://<ALB_DNS>/health

# Test the frontend
open http://<ALB_DNS>
```

## Common Operations

### View Infrastructure Outputs

```bash
make aws-outputs
```

Shows:
- ALB DNS name
- ECR repository URLs
- RDS endpoint
- Redis endpoint
- ECS cluster details

### Update Application

After making code changes:

```bash
make aws-deploy
```

This builds new images and updates ECS tasks with zero downtime.

### View Logs

**Option 1: CloudWatch Logs (AWS Console)**
1. Go to CloudWatch → Log groups
2. Find `/ecs/zero-to-dev-dev-api` or `/ecs/zero-to-dev-dev-frontend`
3. View log streams

**Option 2: AWS CLI**
```bash
# API logs
aws logs tail /ecs/zero-to-dev-dev-api --follow

# Frontend logs
aws logs tail /ecs/zero-to-dev-dev-frontend --follow
```

### Scale Services

Update `infra/terraform/terraform.tfvars`:

```hcl
desired_count = 2  # Number of tasks
min_capacity  = 1
max_capacity  = 5
```

Then apply:
```bash
cd infra/terraform
terraform apply
```

Auto-scaling will automatically adjust between min and max based on CPU usage.

### Destroy Infrastructure

**⚠️ Warning:** This permanently deletes all resources!

```bash
make aws-destroy
```

You'll need to type `destroy` to confirm.

## Modules

### Networking Module (`modules/networking/`)

Creates:
- VPC with customizable CIDR
- Public subnets (2 AZs)
- Private subnets (2 AZs)
- Internet Gateway
- NAT Gateway
- Route tables

**Inputs:**
- `vpc_cidr`: VPC CIDR block (default: `10.0.0.0/16`)
- `availability_zones`: List of AZs (default: `["us-east-1a", "us-east-1b"]`)

### ECR Module (`modules/ecr/`)

Creates:
- ECR repository for API
- ECR repository for Frontend
- Lifecycle policies (keep last 10 images)
- Image scanning enabled

### RDS Module (`modules/rds/`)

Creates:
- PostgreSQL 16 instance
- Security group
- Subnet group
- Parameter group
- Automated backups
- Multi-AZ for production

**Inputs:**
- `db_instance_class`: Instance type (default: `db.t3.micro`)
- `db_allocated_storage`: Storage in GB (default: `20`)
- `db_username`: Master username
- `db_password`: Master password (sensitive)

### ElastiCache Module (`modules/elasticache/`)

Creates:
- Redis 7 cluster
- Security group
- Subnet group
- Parameter group (LRU eviction)

**Inputs:**
- `redis_node_type`: Node type (default: `cache.t3.micro`)
- `redis_num_cache_nodes`: Number of nodes (default: `1`)

### ALB Module (`modules/alb/`)

Creates:
- Application Load Balancer
- Security group
- Target groups (frontend, API)
- HTTP listener with path-based routing
  - `/` → Frontend
  - `/api/*` → API
  - `/health*` → API

### ECS Module (`modules/ecs/`)

Creates:
- ECS Cluster
- IAM roles and policies
- Task definitions (API, Frontend)
- ECS services
- CloudWatch log groups
- Auto-scaling policies (CPU-based)

**Inputs:**
- `api_image`: Docker image for API
- `frontend_image`: Docker image for Frontend
- `api_cpu`: CPU units (default: `256`)
- `api_memory`: Memory in MiB (default: `512`)
- `desired_count`: Number of tasks (default: `1`)

## Troubleshooting

### Issue: `terraform init` fails

**Cause:** Backend not bootstrapped.

**Solution:**
```bash
make aws-bootstrap
```

### Issue: ECS tasks failing health checks

**Causes:**
1. Database not accessible
2. Redis not accessible
3. Application taking too long to start

**Solution:**
```bash
# Check task logs
aws ecs describe-tasks --cluster zero-to-dev-dev-cluster --tasks <task-id>

# View CloudWatch logs
aws logs tail /ecs/zero-to-dev-dev-api --follow
```

### Issue: Can't access ALB URL

**Causes:**
1. Security group blocking traffic
2. Tasks not healthy
3. DNS propagation delay

**Solution:**
```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verify security groups allow port 80
```

### Issue: High AWS costs

**Solutions:**
1. Check for orphaned resources
2. Scale down to single task during off-hours
3. Use Fargate Spot for non-production
4. Consider removing NAT Gateway (use bastion instead)

### Issue: `make aws-deploy` fails during docker push

**Cause:** Not logged in to ECR.

**Solution:**
```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

## Security Best Practices

1. **Never commit secrets** - Use `.gitignore` for `terraform.tfvars`
2. **Use IAM roles** - Don't use root AWS account
3. **Enable MFA** - On all AWS accounts
4. **Rotate credentials** - Regularly update passwords and keys
5. **Review security groups** - Follow principle of least privilege
6. **Enable CloudTrail** - Track all API calls
7. **Use encryption** - RDS and S3 are encrypted by default
8. **Regular backups** - RDS automated backups enabled

## Next Steps

After infrastructure is deployed:

1. **Set up CI/CD** (PR #5): Automate deployments via GitHub Actions
2. **Configure custom domain** (optional): Add Route53 and ACM for HTTPS
3. **Add monitoring** (optional): Set up CloudWatch alarms
4. **Enable WAF** (optional): Add AWS WAF for security

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review AWS Console for resource status
3. Consult Terraform documentation
4. Review error messages carefully

## References

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
