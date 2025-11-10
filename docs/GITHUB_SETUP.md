# GitHub Actions Setup Guide

This guide walks you through setting up GitHub Actions for automated CI/CD deployment to AWS ECS.

---

## Prerequisites

Before configuring GitHub Actions, ensure you have:

1. ✅ AWS account with appropriate permissions
2. ✅ GitHub repository created
3. ✅ Terraform backend bootstrapped (`make aws-bootstrap`)
4. ✅ AWS CLI configured locally

---

## Step 1: Create IAM User for GitHub Actions

GitHub Actions needs AWS credentials to deploy your infrastructure. Follow these steps to create a dedicated IAM user:

### 1.1 Create IAM User

```bash
# Using AWS CLI
aws iam create-user --user-name github-actions-zero-to-dev
```

Or via AWS Console:
1. Go to IAM → Users → Add users
2. User name: `github-actions-zero-to-dev`
3. Select "Access key - Programmatic access"
4. Click "Next"

### 1.2 Create and Attach IAM Policy

Create a custom policy using the policy document in `docs/github-actions-iam-policy.json`:

```bash
# Create policy
aws iam create-policy \
  --policy-name GitHubActionsZeroToDevPolicy \
  --policy-document file://docs/github-actions-iam-policy.json

# Attach policy to user (replace ACCOUNT_ID with your AWS account ID)
aws iam attach-user-policy \
  --user-name github-actions-zero-to-dev \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsZeroToDevPolicy
```

**If the policy already exists**, update it with the latest version:

```bash
# Create a new policy version and set it as default (replace ACCOUNT_ID with your AWS account ID)
aws iam create-policy-version \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsZeroToDevPolicy \
  --policy-document file://docs/github-actions-iam-policy.json \
  --set-as-default
```

**Note:** If you have multiple versions, you may want to delete old versions after verifying the new one works:
```bash
# List policy versions
aws iam list-policy-versions \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsZeroToDevPolicy

# Delete old version (replace VERSION_ID with the version to delete)
aws iam delete-policy-version \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsZeroToDevPolicy \
  --version-id VERSION_ID
```

Or via AWS Console:
1. Go to IAM → Policies → Create policy
2. Switch to JSON tab
3. Copy contents from `docs/github-actions-iam-policy.json`
4. Name: `GitHubActionsZeroToDevPolicy`
5. Create policy
6. Go back to Users → `github-actions-zero-to-dev` → Add permissions
7. Attach the policy you just created

**To update an existing policy via Console:**
1. Go to IAM → Policies
2. Find and click on `GitHubActionsZeroToDevPolicy`
3. Click "Edit" → "Edit policy"
4. Switch to JSON tab
5. Copy and paste the latest contents from `docs/github-actions-iam-policy.json`
6. Click "Review policy" → "Save changes"

### 1.3 Create Access Keys

```bash
# Create access key
aws iam create-access-key --user-name github-actions-zero-to-dev
```

**Important:** Save the output! You'll need:
- `AccessKeyId`
- `SecretAccessKey`

⚠️ **Security Note:** These credentials have powerful permissions. Store them securely and never commit them to your repository.

---

## Step 2: Configure GitHub Secrets

GitHub Secrets allow you to securely store sensitive information like AWS credentials.

### 2.1 Add Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AWS_ACCESS_KEY_ID` | Your IAM access key ID | From Step 1.3 |
| `AWS_SECRET_ACCESS_KEY` | Your IAM secret access key | From Step 1.3 |
| `DB_PASSWORD` | Strong database password | Used for RDS PostgreSQL |

### 2.2 Verify Secrets

After adding secrets, you should see:
- ✅ `AWS_ACCESS_KEY_ID`
- ✅ `AWS_SECRET_ACCESS_KEY`
- ✅ `DB_PASSWORD`

---

## Step 3: Configure Terraform Variables

Update your `infra/terraform/terraform.tfvars` file to support the new image variables:

```hcl
# Add these variables to support GitHub Actions deployment
frontend_image = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zero-to-dev-frontend:latest"
api_image      = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/zero-to-dev-api:latest"
```

Add corresponding variable definitions to `infra/terraform/variables.tf`:

```hcl
variable "frontend_image" {
  description = "Docker image for frontend"
  type        = string
}

variable "api_image" {
  description = "Docker image for API"
  type        = string
}
```

---

## Step 4: Test the Pipeline

### 4.1 Test PR Checks

1. Create a new branch:
   ```bash
   git checkout -b test-ci
   ```

2. Make a small change (e.g., update README.md)

3. Commit and push:
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin test-ci
   ```

4. Open a Pull Request on GitHub

5. Verify that **PR Checks** workflow runs automatically:
   - ✅ Builds API
   - ✅ Builds Frontend
   - ✅ Starts Docker Compose
   - ✅ Runs health checks
   - ✅ All checks pass

### 4.2 Test Deployment

1. Merge the PR to `main`

2. Verify that **Deploy to AWS ECS** workflow runs automatically:
   - ✅ Builds Docker images
   - ✅ Pushes to ECR
   - ✅ Runs Terraform apply
   - ✅ Outputs ALB URL

3. Access your application:
   ```bash
   # Get the ALB URL from workflow output or run:
   cd infra/terraform
   terraform output alb_url
   ```

4. Verify the application is accessible:
   ```bash
   curl http://YOUR_ALB_URL/health
   ```

---

## Step 5: Monitor Deployments

### 5.1 View Workflow Runs

1. Go to your GitHub repository
2. Click **Actions** tab
3. View all workflow runs and their status

### 5.2 View Logs

Click on any workflow run to see detailed logs for each step.

### 5.3 Re-run Failed Workflows

If a workflow fails, you can:
1. Click on the failed workflow run
2. Click **Re-run all jobs**
3. Or **Re-run failed jobs** to only retry failed steps

---

## Troubleshooting

### Issue: AWS Credentials Invalid

**Error:** `Unable to locate credentials`

**Solution:**
1. Verify secrets are set correctly in GitHub repository settings
2. Check IAM user has correct permissions
3. Verify access keys are active in AWS Console

### Issue: ECR Push Permission Denied

**Error:** `denied: User is not authorized to perform: ecr:PutImage`

**Solution:**
1. Verify IAM policy includes ECR permissions
2. Check ECR repository exists (created by Terraform bootstrap)
3. Verify AWS region matches in workflow

### Issue: RDS Permission Denied

**Error:** `User is not authorized to perform: rds:DescribeDBParameters`

**Solution:**
1. Verify the IAM policy has been updated with the latest version from `docs/github-actions-iam-policy.json`
2. Update the policy in AWS using one of these methods:
   ```bash
   # Using AWS CLI (replace ACCOUNT_ID with your AWS account ID)
   aws iam create-policy-version \
     --policy-arn arn:aws:iam::ACCOUNT_ID:policy/GitHubActionsZeroToDevPolicy \
     --policy-document file://docs/github-actions-iam-policy.json \
     --set-as-default
   ```
3. Or update via AWS Console:
   - Go to IAM → Policies → `GitHubActionsZeroToDevPolicy`
   - Click "Edit" → "Edit policy" → JSON tab
   - Copy contents from `docs/github-actions-iam-policy.json`
   - Save changes
4. Wait a few seconds for the policy changes to propagate
5. Re-run the Terraform plan/apply

**Note:** The policy file already includes `rds:DescribeDBParameters` - the issue is that the policy in AWS needs to be updated to match the file.

### Issue: Terraform Apply Fails

**Error:** `Error acquiring the state lock`

**Solution:**
1. Check DynamoDB table exists (from bootstrap)
2. Verify no other Terraform process is running
3. If stuck, manually release lock in DynamoDB

### Issue: ECS Task Fails to Start

**Error:** `Task failed to start`

**Solution:**
1. Check CloudWatch logs for ECS tasks
2. Verify Docker image was pushed successfully
3. Check security group rules allow traffic
4. Verify RDS and ElastiCache are accessible from ECS

### Issue: Health Checks Fail

**Error:** `Health check failed`

**Solution:**
1. Check ALB target group health checks
2. Verify application is listening on correct port
3. Check container logs in CloudWatch
4. Verify environment variables are set correctly

---

## Security Best Practices

### 1. Rotate Access Keys Regularly

```bash
# Create new access key
aws iam create-access-key --user-name github-actions-zero-to-dev

# Update GitHub secrets with new keys

# Delete old access key
aws iam delete-access-key \
  --user-name github-actions-zero-to-dev \
  --access-key-id OLD_ACCESS_KEY_ID
```

### 2. Use Least Privilege

The IAM policy provided follows least privilege principles. Review and adjust as needed for your use case.

### 3. Enable MFA for Production

For production environments, consider requiring MFA for destructive operations.

### 4. Monitor IAM Activity

Enable CloudTrail to monitor API calls made by the IAM user:
```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=Username,AttributeValue=github-actions-zero-to-dev
```

### 5. Review Access Regularly

Periodically review IAM permissions and remove any that are no longer needed.

---

## Additional Configuration

### Environment-Specific Deployments

To deploy to multiple environments (dev, staging, prod):

1. Create separate workflow files:
   - `.github/workflows/deploy-dev.yml`
   - `.github/workflows/deploy-staging.yml`
   - `.github/workflows/deploy-prod.yml`

2. Use different Terraform workspaces or directories

3. Create separate GitHub environments with protection rules

### Approval Gates for Production

Add manual approval for production deployments:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.deploy.outputs.url }}
```

Then configure protection rules in GitHub repository settings.

---

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions AWS Credentials](https://github.com/aws-actions/configure-aws-credentials)

---

## Summary

After completing this setup:

✅ GitHub Actions can deploy to AWS automatically  
✅ PR checks validate code before merging  
✅ Deployment happens on every merge to main  
✅ Infrastructure is managed as code  
✅ Credentials are stored securely  

Your CI/CD pipeline is now fully automated! 🎉

