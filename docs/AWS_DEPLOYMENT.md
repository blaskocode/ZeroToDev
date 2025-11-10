# AWS Deployment Guide

Deploy the Zero-to-Running Developer Environment to AWS with complete infrastructure automation.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Cost Estimate](#cost-estimate)
- [Deployment Steps](#deployment-steps)
- [Post-Deployment](#post-deployment)
- [Managing Your Deployment](#managing-your-deployment)
- [Monitoring](#monitoring)
- [Scaling](#scaling)
- [Security](#security)
- [Teardown](#teardown)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project uses **Terraform** to provision a complete AWS infrastructure:

```
┌─────────────────────────────────────────────────────────┐
│                      AWS Cloud                           │
│                                                          │
│  Internet → ALB → ECS (Fargate) → RDS PostgreSQL       │
│                    ↓                ↓ ElastiCache Redis  │
│              Auto-scaling      Private Subnets           │
└─────────────────────────────────────────────────────────┘
```

### What Gets Created

- **VPC**: Custom VPC with public and private subnets across 2 availability zones
- **ECS Cluster**: Fargate-based container orchestration
- **RDS**: PostgreSQL 16 database instance
- **ElastiCache**: Redis 7 cache cluster
- **ALB**: Application Load Balancer with path-based routing
- **ECR**: Docker image repositories
- **Security Groups**: Network isolation and access control
- **CloudWatch**: Centralized logging and monitoring
- **Auto-scaling**: Automatic task scaling based on CPU usage

---

## Prerequisites

### Required Tools

Install these tools before beginning:

```bash
# Check versions
aws --version      # Required: >= 2.0
terraform --version # Required: >= 1.0
docker --version    # Required: >= 24.0
git --version      # Required: >= 2.0
```

If not installed, see:
- **AWS CLI**: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- **Terraform**: https://developer.hashicorp.com/terraform/downloads
- **Docker**: https://docs.docker.com/get-docker/

### AWS Account Setup

1. **Create AWS Account** (if needed):
   - Visit https://aws.amazon.com/
   - Follow signup process
   - Enable MFA for root account (highly recommended)

2. **Create IAM User** for deployments:
   ```bash
   # Via AWS Console:
   # 1. Go to IAM → Users → Create User
   # 2. Name: "terraform-deploy"
   # 3. Attach policy (see docs/github-actions-iam-policy.json)
   # 4. Create access key
   ```

3. **Configure AWS CLI**:
   ```bash
   aws configure
   ```
   
   Enter:
   - **AWS Access Key ID**: [Your access key]
   - **AWS Secret Access Key**: [Your secret key]
   - **Default region**: `us-east-1` (or your preferred region)
   - **Default output format**: `json`

4. **Verify configuration**:
   ```bash
   aws sts get-caller-identity
   ```
   
   Should display your account ID and user ARN.

### Required AWS Permissions

Your IAM user needs permissions for:
- **S3**: Terraform state storage
- **DynamoDB**: State locking
- **EC2/VPC**: Networking resources
- **ECS**: Container orchestration
- **ECR**: Docker image storage
- **RDS**: Database management
- **ElastiCache**: Redis cache
- **ELB**: Load balancer
- **IAM**: Role and policy management
- **CloudWatch**: Logs and monitoring

See `docs/github-actions-iam-policy.json` for a complete IAM policy.

---

## Cost Estimate

**Estimated Monthly Cost (US East 1, development environment):**

| Service | Configuration | Monthly Cost |
|---------|--------------|--------------|
| ECS Fargate | 2 tasks (0.25 vCPU, 0.5 GB RAM) | ~$15 |
| RDS PostgreSQL | db.t3.micro, 20GB, Single-AZ | ~$15 |
| ElastiCache Redis | cache.t3.micro | ~$12 |
| Application Load Balancer | 1 ALB | ~$16 |
| NAT Gateway | 1 NAT Gateway | ~$32 |
| Data Transfer | Minimal usage | ~$5 |
| **Total** | | **~$95/month** |

### Cost Optimization Tips

**For Development/Testing:**
- Use Fargate Spot (50-70% savings)
- Use single availability zone (reduces NAT Gateway costs)
- Scale ECS tasks to 0 during off-hours
- Use auto-scaling to scale down when idle
- Use db.t4g.micro instead of t3.micro (ARM instances, cheaper)

**NAT Gateway Alternative:**
The NAT Gateway is the single most expensive component (~$32/month). For dev environments, you can:
- Use a bastion host instead (cheaper but requires maintenance)
- Place ECS tasks in public subnets (not recommended for production)

**For Production:**
- Enable Multi-AZ for RDS (high availability)
- Use larger instance types as needed
- Enable ALB access logs (minimal cost, valuable for debugging)
- Set up CloudWatch alarms (minimal cost)

---

## Deployment Steps

### Step 1: Bootstrap Terraform Backend

Before the first deployment, create S3 bucket and DynamoDB table for Terraform state:

```bash
make aws-bootstrap
```

This runs `infra/scripts/bootstrap-terraform.sh` which:
- Creates S3 bucket: `zero-to-dev-terraform-state`
- Enables versioning and encryption on the bucket
- Blocks all public access
- Creates DynamoDB table: `zero-to-dev-terraform-locks`
- Enables point-in-time recovery

**⚠️ This is a one-time operation!** You only need to run this once per AWS account/region.

**Verify it worked:**
```bash
aws s3 ls | grep zero-to-dev
aws dynamodb list-tables | grep zero-to-dev
```

### Step 2: Configure Terraform Variables

Create `infra/terraform/terraform.tfvars`:

```hcl
# AWS Configuration
aws_region   = "us-east-1"
environment  = "dev"
project_name = "zero-to-dev"

# Database Configuration
db_username = "dbadmin"
db_password = "ChangeMe123!SecurePassword"  # CHANGE THIS!

# Optional: Override defaults
# vpc_cidr = "10.0.0.0/16"
# db_instance_class = "db.t3.micro"
# db_allocated_storage = 20
# redis_node_type = "cache.t3.micro"
# api_cpu = 256
# api_memory = 512
# desired_count = 1
# min_capacity = 1
# max_capacity = 3
```

**⚠️ Security Warning:**
- **NEVER commit `terraform.tfvars` to git!** (Already in `.gitignore`)
- Use a **strong database password** (16+ characters, mixed case, numbers, symbols)
- Consider using AWS Secrets Manager for production

**Available variables** (see `infra/terraform/variables.tf` for all options):
- `aws_region`: AWS region (default: us-east-1)
- `environment`: Environment name (dev/staging/prod)
- `project_name`: Project name prefix
- `db_username`: RDS master username
- `db_password`: RDS master password (sensitive)
- `db_instance_class`: RDS instance type
- `redis_node_type`: ElastiCache node type
- `desired_count`: Number of ECS tasks
- `min_capacity`: Minimum tasks for auto-scaling
- `max_capacity`: Maximum tasks for auto-scaling

### Step 3: Review Infrastructure Plan

Preview what Terraform will create:

```bash
make aws-plan
```

Review the output carefully. You should see:
- ~40-50 resources to be created
- VPC with subnets
- ECS cluster and services
- RDS instance
- ElastiCache cluster
- Load balancer
- Security groups
- IAM roles

**Look for:**
- ✅ No destruction of existing resources (on first deploy)
- ✅ Reasonable instance sizes
- ✅ Correct region

**If something looks wrong:**
- Check `terraform.tfvars`
- Verify AWS credentials
- Check region configuration

### Step 4: Deploy to AWS

Build Docker images and deploy infrastructure:

```bash
make aws-deploy
```

This runs `infra/scripts/deploy.sh` which:
1. Builds API Docker image (production target)
2. Builds Frontend Docker image (production target with Nginx)
3. Logs in to ECR
4. Pushes images to ECR with `latest` tag
5. Runs `terraform init`
6. Runs `terraform apply` with auto-approval
7. Outputs the ALB DNS name

**⏱️ Expected Duration:**
- **First deployment**: 10-15 minutes
  - VPC creation: ~2 min
  - RDS instance: ~5-7 min
  - ECS cluster: ~3-5 min
  - Everything else: ~2-3 min

**What happens:**
1. **Terraform** provisions all infrastructure
2. **RDS** initializes PostgreSQL database
3. **ElastiCache** starts Redis cluster
4. **ECS** pulls Docker images from ECR
5. **ECS tasks** start and run health checks
6. **ALB** registers healthy targets
7. **Output** displays the ALB DNS name

**Watch progress:**
```bash
# In another terminal
watch -n 5 'aws ecs describe-services --cluster zero-to-dev-dev-cluster --services zero-to-dev-dev-api --query "services[0].events[0:5]"'
```

### Step 5: Verify Deployment

After deployment completes, test your application:

```bash
# Get the ALB DNS name
make aws-outputs

# Should show something like:
# alb_url = "zero-to-dev-dev-alb-1234567890.us-east-1.elb.amazonaws.com"
```

**Test endpoints:**

1. **API Health Check:**
   ```bash
   ALB_URL="your-alb-dns-here"
   curl http://$ALB_URL/health
   
   # Expected: {"status":"ok","timestamp":"2025-11-10T..."}
   ```

2. **Comprehensive Health Check:**
   ```bash
   curl http://$ALB_URL/health/all
   
   # Should show database and Redis are healthy
   ```

3. **Frontend:**
   ```bash
   open http://$ALB_URL
   # Or in browser: http://your-alb-dns
   
   # Should display the health dashboard
   ```

**✅ Success indicators:**
- API health endpoint returns 200 OK
- Frontend loads in browser
- Health dashboard shows all services healthy
- No 503 errors from ALB

---

## Post-Deployment

### Access Your Infrastructure

**AWS Console:**
- **ECS**: https://console.aws.amazon.com/ecs → Clusters → zero-to-dev-dev-cluster
- **RDS**: https://console.aws.amazon.com/rds → Databases
- **ElastiCache**: https://console.aws.amazon.com/elasticache → Redis
- **Load Balancer**: https://console.aws.amazon.com/ec2 → Load Balancers
- **CloudWatch**: https://console.aws.amazon.com/cloudwatch → Log groups

**View all outputs:**
```bash
make aws-outputs
```

Shows:
- ALB DNS name
- ECR repository URLs
- RDS endpoint
- Redis endpoint
- ECS cluster ARN
- VPC ID

### Connect to Database

**From ECS tasks** (automatic):
- Tasks already have access via security groups
- Use `DATABASE_URL` environment variable

**From your local machine:**
```bash
# Get RDS endpoint
make aws-outputs | grep rds_endpoint

# Connect via psql (requires security group modification)
psql -h <rds-endpoint> -U dbadmin -d appdb

# Note: By default, RDS is NOT publicly accessible (security best practice)
# To connect locally, you'd need to:
# 1. Enable public access (not recommended) OR
# 2. Use SSH tunnel through bastion OR
# 3. Use AWS Session Manager
```

### View Logs

**Via AWS Console:**
1. Go to CloudWatch → Log groups
2. Find `/ecs/zero-to-dev-dev-api` or `/ecs/zero-to-dev-dev-frontend`
3. Select a log stream

**Via AWS CLI:**
```bash
# API logs
aws logs tail /ecs/zero-to-dev-dev-api --follow

# Frontend logs
aws logs tail /ecs/zero-to-dev-dev-frontend --follow

# Last 100 lines
aws logs tail /ecs/zero-to-dev-dev-api --since 1h
```

### Set Up CloudWatch Alarms (Optional)

Create alarms for important metrics:

```bash
# CPU Utilization
aws cloudwatch put-metric-alarm \
  --alarm-name zero-to-dev-high-cpu \
  --alarm-description "Alert when CPU exceeds 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ClusterName,Value=zero-to-dev-dev-cluster

# Memory Utilization
aws cloudwatch put-metric-alarm \
  --alarm-name zero-to-dev-high-memory \
  --alarm-description "Alert when memory exceeds 80%" \
  --metric-name MemoryUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=ClusterName,Value=zero-to-dev-dev-cluster
```

---

## Managing Your Deployment

### Update Application Code

After making code changes:

```bash
make aws-deploy
```

This will:
1. Build new Docker images
2. Push to ECR with new tags
3. Update ECS task definitions
4. Deploy new tasks (zero-downtime deployment)

ECS will:
1. Start new tasks with updated image
2. Wait for health checks to pass
3. Drain connections from old tasks
4. Stop old tasks

**Watch deployment:**
```bash
aws ecs describe-services \
  --cluster zero-to-dev-dev-cluster \
  --services zero-to-dev-dev-api \
  --query "services[0].events[0:10]"
```

### Update Infrastructure

To change infrastructure (instance sizes, scaling, etc.):

1. **Edit `infra/terraform/terraform.tfvars`:**
   ```hcl
   desired_count = 2  # Increase from 1 to 2
   max_capacity = 5   # Increase max auto-scaling
   ```

2. **Plan changes:**
   ```bash
   make aws-plan
   ```

3. **Apply changes:**
   ```bash
   cd infra/terraform
   terraform apply
   ```

---

## Monitoring

### CloudWatch Dashboard

Create a custom dashboard:

```bash
# Via AWS Console:
# CloudWatch → Dashboards → Create dashboard
# Add widgets for:
# - ECS CPU/Memory utilization
# - ALB request count
# - RDS connections
# - ElastiCache hit rate
```

### Key Metrics to Monitor

| Metric | Threshold | Action |
|--------|-----------|--------|
| ECS CPU > 80% | Alert | Scale up or optimize code |
| ECS Memory > 80% | Alert | Scale up or fix memory leaks |
| ALB 5xx errors | > 1% | Check application logs |
| RDS CPU > 75% | Alert | Scale up instance or optimize queries |
| RDS Connections > 80% | Alert | Review connection pooling |
| Redis CPU > 75% | Alert | Scale up or optimize cache usage |

### Log Analysis

**Search logs:**
```bash
# Find errors in last hour
aws logs filter-log-events \
  --log-group-name /ecs/zero-to-dev-dev-api \
  --start-time $(date -u -d '1 hour ago' +%s)000 \
  --filter-pattern "ERROR"

# Find slow queries
aws logs filter-log-events \
  --log-group-name /ecs/zero-to-dev-dev-api \
  --filter-pattern "\"slow query\""
```

---

## Scaling

### Manual Scaling

**Scale ECS tasks:**
```bash
# Scale up
aws ecs update-service \
  --cluster zero-to-dev-dev-cluster \
  --service zero-to-dev-dev-api \
  --desired-count 3

# Scale down
aws ecs update-service \
  --cluster zero-to-dev-dev-cluster \
  --service zero-to-dev-dev-api \
  --desired-count 1
```

**Scale RDS:**
```bash
# Upgrade instance class
cd infra/terraform
# Edit terraform.tfvars: db_instance_class = "db.t3.small"
terraform apply

# Note: This causes downtime during modification
```

### Auto-Scaling

Auto-scaling is already configured for ECS:
- **Target metric**: CPU utilization 70%
- **Min tasks**: 1 (configurable)
- **Max tasks**: 3 (configurable)
- **Scale-up**: Add tasks when CPU > 70% for 2 minutes
- **Scale-down**: Remove tasks when CPU < 50% for 5 minutes

**Adjust auto-scaling** in `terraform.tfvars`:
```hcl
min_capacity = 1
max_capacity = 10
```

---

## Security

### Security Best Practices

**✅ Already Implemented:**
- RDS in private subnet (no public access)
- ElastiCache in private subnet
- Security groups with least privilege
- ECS task IAM roles (no hardcoded credentials)
- S3 state bucket encryption
- RDS encryption at rest
- HTTPS between ALB and tasks (optional: enable HTTPS on ALB)

**🔒 Additional Recommendations:**

1. **Enable HTTPS on ALB:**
   - Request ACM certificate
   - Add HTTPS listener to ALB
   - Redirect HTTP to HTTPS

2. **Enable AWS WAF** (Web Application Firewall):
   - Protect against common exploits
   - Rate limiting
   - Geo-blocking if needed

3. **Secrets Management:**
   - Use AWS Secrets Manager for database passwords
   - Rotate credentials regularly

4. **VPC Flow Logs:**
   - Enable to track network traffic
   - Useful for security audits

5. **GuardDuty:**
   - Enable for threat detection
   - Monitors for suspicious activity

### Security Groups

Default security groups allow:

| Source | Port | Service | Purpose |
|--------|------|---------|---------|
| ALB | 80 | ECS Tasks | HTTP traffic |
| ECS Tasks | 5432 | RDS | Database access |
| ECS Tasks | 6379 | ElastiCache | Cache access |
| Internet | 80 | ALB | Public HTTP access |

**To modify**, edit `infra/terraform/modules/*/main.tf`

---

## Teardown

### Destroy Infrastructure

**⚠️ WARNING: This permanently deletes ALL resources and data!**

```bash
make aws-destroy
```

You'll be prompted to type `yes` to confirm.

**What gets deleted:**
- All ECS tasks and services
- Load balancer
- RDS database (including all data)
- ElastiCache cluster
- VPC and networking resources
- CloudWatch log groups (data retained for 30 days by default)
- ECR images

**What survives:**
- S3 Terraform state bucket (manual deletion required)
- DynamoDB state lock table (manual deletion required)
- CloudWatch Logs (retention period)

**Manual cleanup** (if desired):
```bash
# Delete S3 bucket
aws s3 rb s3://zero-to-dev-terraform-state --force

# Delete DynamoDB table
aws dynamodb delete-table --table-name zero-to-dev-terraform-locks

# Delete ECR images
aws ecr delete-repository --repository-name zero-to-dev-api --force
aws ecr delete-repository --repository-name zero-to-dev-frontend --force
```

---

## Troubleshooting

See [TROUBLESHOOTING.md](../TROUBLESHOOTING.md#aws-deployment-issues) for detailed solutions.

### Common Issues

**Terraform init fails:**
```bash
# Run bootstrap first
make aws-bootstrap
```

**ECR push fails:**
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

**ECS tasks not starting:**
```bash
# Check logs
aws logs tail /ecs/zero-to-dev-dev-api --follow

# Describe tasks
aws ecs describe-tasks \
  --cluster zero-to-dev-dev-cluster \
  --tasks $(aws ecs list-tasks --cluster zero-to-dev-dev-cluster --query 'taskArns[0]' --output text)
```

**ALB returns 503:**
```bash
# Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups --query 'TargetGroups[0].TargetGroupArn' --output text)
```

---

## Next Steps

- **Set up CI/CD**: See [GitHub Setup Guide](GITHUB_SETUP.md)
- **Custom domain**: Use Route53 and ACM for HTTPS
- **Monitoring**: Set up CloudWatch dashboards and alarms
- **Backups**: Configure automated RDS snapshots
- **Performance**: Enable ALB access logs for analysis

---

## Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Infrastructure README](../infra/README.md) - Detailed module documentation

---

**Need help?** Check the [Troubleshooting Guide](../TROUBLESHOOTING.md) or [open an issue](../../issues).

