# QA Checklist

Comprehensive testing checklist for Zero-to-Running Developer Environment.

Use this checklist before releases, after major changes, or to verify your setup.

---

## Local Development Environment

### Initial Setup

- [ ] **Repository clone**
  ```bash
  git clone <repository-url>
  cd ZeroToDev
  ```

- [ ] **Prerequisites validation**
  ```bash
  ./scripts/validate-prereqs.sh
  ```
  - [ ] Docker version >= 24.0
  - [ ] Docker Compose version >= 2.0
  - [ ] Make available
  - [ ] Node.js version >= 20.0
  - [ ] npm version >= 10.0
  - [ ] Git version >= 2.0

- [ ] **Environment configuration**
  ```bash
  cp .env.example .env
  ```
  - [ ] `.env` file created
  - [ ] All required variables present

### Service Startup

- [ ] **Start services**
  ```bash
  make dev
  ```
  - [ ] Command completes without errors
  - [ ] ASCII banner displays
  - [ ] Prerequisites check passes
  - [ ] Docker Compose starts all services
  - [ ] PostgreSQL health check passes
  - [ ] Redis health check passes
  - [ ] API health check passes
  - [ ] Frontend health check passes
  - [ ] Success message displays with URLs
  - [ ] **Startup time** < 10 minutes (first time)
  - [ ] **Startup time** < 2 minutes (subsequent)

- [ ] **Check service status**
  ```bash
  make status
  ```
  - [ ] All services show as "running"
  - [ ] Port mappings displayed correctly
  - [ ] Resource usage shown

### Frontend Testing

- [ ] **Access frontend**
  - [ ] Open http://localhost:5173
  - [ ] Page loads without errors
  - [ ] No console errors in browser
  - [ ] Health dashboard displays

- [ ] **UI Components**
  - [ ] Service cards render correctly
  - [ ] Status indicators show colors (green = healthy)
  - [ ] System metrics display
  - [ ] Memory usage shows progress bar
  - [ ] Uptime displays correctly
  - [ ] Platform info visible

- [ ] **Theme Toggle**
  - [ ] Light/dark theme toggle button visible
  - [ ] Clicking toggle switches theme
  - [ ] Theme applies to all components
  - [ ] Smooth transitions

- [ ] **Real-time Updates**
  - [ ] Status updates every 5 seconds
  - [ ] No flashing or flickering
  - [ ] Timestamps update correctly
  - [ ] Loading states handled gracefully

- [ ] **Error Handling**
  - [ ] Stop API: `docker stop zero-to-dev-api`
  - [ ] Frontend shows error message
  - [ ] Error is user-friendly
  - [ ] Restart API: `docker start zero-to-dev-api`
  - [ ] Frontend recovers automatically

- [ ] **Responsive Design**
  - [ ] Desktop view (>1024px)
  - [ ] Tablet view (768px - 1024px)
  - [ ] Mobile view (<768px)
  - [ ] All elements readable and accessible

### API Testing

- [ ] **Basic health check**
  ```bash
  curl http://localhost:4000/health
  ```
  - [ ] Returns 200 OK
  - [ ] JSON response: `{"status":"ok","timestamp":"..."}`

- [ ] **Database health check**
  ```bash
  curl http://localhost:4000/health/db
  ```
  - [ ] Returns 200 OK
  - [ ] Shows database connectivity

- [ ] **Cache health check**
  ```bash
  curl http://localhost:4000/health/cache
  ```
  - [ ] Returns 200 OK
  - [ ] Shows Redis connectivity

- [ ] **Comprehensive health check**
  ```bash
  curl http://localhost:4000/health/all
  ```
  - [ ] Returns 200 OK
  - [ ] Includes all service statuses
  - [ ] Shows memory usage
  - [ ] Shows uptime
  - [ ] Shows platform info

- [ ] **CORS Headers**
  ```bash
  curl -H "Origin: http://localhost:5173" -v http://localhost:4000/health
  ```
  - [ ] `Access-Control-Allow-Origin` header present

### Database Testing

- [ ] **PostgreSQL access**
  ```bash
  docker exec -it zero-to-dev-db psql -U dev -d appdb
  ```
  - [ ] Connection successful
  - [ ] Can execute queries: `SELECT version();`
  - [ ] Exit with `\q`

- [ ] **Migration verification**
  ```bash
  docker exec -it zero-to-dev-db psql -U dev -d appdb -c "SELECT * FROM migrations;"
  ```
  - [ ] Migrations table exists
  - [ ] Contains `001_initial_schema`

- [ ] **Health checks table**
  ```bash
  docker exec -it zero-to-dev-db psql -U dev -d appdb -c "SELECT * FROM health_checks;"
  ```
  - [ ] Table exists
  - [ ] Can query without errors

- [ ] **Data persistence**
  - [ ] Insert test data
  - [ ] Run `make down`
  - [ ] Run `make dev`
  - [ ] Verify data still exists

### Redis Testing

- [ ] **Redis access**
  ```bash
  docker exec -it zero-to-dev-redis redis-cli
  ```
  - [ ] Connection successful
  - [ ] Run `PING` → responds `PONG`
  - [ ] Run `SET test "hello"` → responds `OK`
  - [ ] Run `GET test` → responds `"hello"`
  - [ ] Exit with `quit`

- [ ] **Cache functionality**
  - [ ] API uses Redis for caching
  - [ ] Cache keys visible in Redis
  - [ ] Cache TTL works correctly

### Hot Reload Testing

- [ ] **Frontend hot reload**
  - [ ] Edit `frontend/src/App.tsx`
  - [ ] Change text (e.g., page title)
  - [ ] Save file
  - [ ] Browser updates automatically (no manual refresh)
  - [ ] Change applies within 2 seconds

- [ ] **API hot reload**
  - [ ] Edit `api/src/routes/health.routes.ts`
  - [ ] Change response message
  - [ ] Save file
  - [ ] Check logs: `make logs | grep api`
  - [ ] See "Restarting..." message
  - [ ] Test endpoint shows new response
  - [ ] Restart completes within 3 seconds

### Logging

- [ ] **View all logs**
  ```bash
  make logs
  ```
  - [ ] Logs from all services display
  - [ ] Logs are colored/formatted
  - [ ] Can Ctrl+C to exit

- [ ] **Individual service logs**
  ```bash
  docker logs zero-to-dev-api -f
  docker logs zero-to-dev-frontend -f
  docker logs zero-to-dev-db -f
  docker logs zero-to-dev-redis -f
  ```
  - [ ] Each service's logs accessible
  - [ ] No unexpected errors

### Cleanup

- [ ] **Stop services**
  ```bash
  make down
  ```
  - [ ] All containers stop gracefully
  - [ ] No errors displayed
  - [ ] Port 5173, 4000, 5432, 6379 freed

- [ ] **Verify stopped**
  ```bash
  docker ps | grep zero-to-dev
  ```
  - [ ] No containers running

- [ ] **Data persistence**
  - [ ] Run `make dev` again
  - [ ] Database data still exists
  - [ ] No need to re-run migrations

- [ ] **Clean everything**
  ```bash
  make clean
  ```
  - [ ] All containers removed
  - [ ] All volumes removed
  - [ ] Database data deleted
  - [ ] Redis data deleted

- [ ] **Fresh start**
  ```bash
  make dev
  ```
  - [ ] Migrations run again
  - [ ] Empty database
  - [ ] Everything works

---

## AWS Deployment

### Prerequisites

- [ ] **AWS CLI configured**
  ```bash
  aws sts get-caller-identity
  ```
  - [ ] Returns account ID
  - [ ] Correct AWS account

- [ ] **Terraform installed**
  ```bash
  terraform version
  ```
  - [ ] Version >= 1.0

- [ ] **IAM permissions**
  - [ ] Reviewed `docs/github-actions-iam-policy.json`
  - [ ] User has required permissions

### Bootstrap (One-time)

- [ ] **Bootstrap Terraform backend**
  ```bash
  make aws-bootstrap
  ```
  - [ ] S3 bucket created: `zero-to-dev-terraform-state`
  - [ ] Bucket versioning enabled
  - [ ] Bucket encryption enabled
  - [ ] Public access blocked
  - [ ] DynamoDB table created: `zero-to-dev-terraform-locks`
  - [ ] No errors

- [ ] **Verify resources**
  ```bash
  aws s3 ls | grep zero-to-dev
  aws dynamodb list-tables | grep zero-to-dev
  ```
  - [ ] S3 bucket exists
  - [ ] DynamoDB table exists

### Configuration

- [ ] **Create terraform.tfvars**
  ```bash
  cd infra/terraform
  cp terraform.tfvars.example terraform.tfvars
  ```
  - [ ] File created
  - [ ] Updated `db_password` (strong password)
  - [ ] Reviewed other variables

- [ ] **Verify .gitignore**
  - [ ] `terraform.tfvars` in `.gitignore`
  - [ ] Will not be committed to git

### Infrastructure Plan

- [ ] **Terraform plan**
  ```bash
  make aws-plan
  ```
  - [ ] No errors
  - [ ] Shows ~40-50 resources to create
  - [ ] VPC and subnets listed
  - [ ] ECS cluster listed
  - [ ] RDS instance listed
  - [ ] ElastiCache cluster listed
  - [ ] ALB listed
  - [ ] No unexpected deletions
  - [ ] Plan makes sense

### Deployment

- [ ] **Deploy to AWS**
  ```bash
  make aws-deploy
  ```
  - [ ] Docker images build successfully (API)
  - [ ] Docker images build successfully (Frontend)
  - [ ] ECR login successful
  - [ ] Images pushed to ECR
  - [ ] Terraform init successful
  - [ ] Terraform apply successful
  - [ ] **Deployment time** < 15 minutes (first time)
  - [ ] ALB DNS name displayed

- [ ] **Save ALB URL**
  ```bash
  make aws-outputs | grep alb_url
  ```
  - [ ] Copy ALB DNS name

### Verification

- [ ] **API health check**
  ```bash
  ALB_URL="your-alb-dns-here"
  curl http://$ALB_URL/health
  ```
  - [ ] Returns 200 OK
  - [ ] JSON response with status

- [ ] **Comprehensive health**
  ```bash
  curl http://$ALB_URL/health/all
  ```
  - [ ] Returns 200 OK
  - [ ] Database connectivity OK
  - [ ] Redis connectivity OK
  - [ ] All services healthy

- [ ] **Frontend access**
  - [ ] Open `http://[ALB_URL]` in browser
  - [ ] Page loads
  - [ ] Health dashboard displays
  - [ ] All services show as healthy
  - [ ] Real-time updates work

- [ ] **Load balancer**
  - [ ] ALB accessible from internet
  - [ ] No 503 errors
  - [ ] Response time < 2 seconds

### ECS Tasks

- [ ] **Check running tasks**
  ```bash
  aws ecs list-tasks --cluster zero-to-dev-dev-cluster
  ```
  - [ ] At least 2 tasks running (API + Frontend)

- [ ] **Task health**
  ```bash
  aws ecs describe-tasks --cluster zero-to-dev-dev-cluster --tasks [task-id]
  ```
  - [ ] Tasks in RUNNING state
  - [ ] Health checks passing

### RDS Database

- [ ] **RDS instance**
  - [ ] Instance status: Available
  - [ ] Can connect from ECS tasks
  - [ ] Backups configured
  - [ ] Encryption enabled

### ElastiCache Redis

- [ ] **Redis cluster**
  - [ ] Status: Available
  - [ ] Can connect from ECS tasks
  - [ ] Correct node type

### CloudWatch Logs

- [ ] **API logs**
  ```bash
  aws logs tail /ecs/zero-to-dev-dev-api --follow
  ```
  - [ ] Logs streaming
  - [ ] No errors

- [ ] **Frontend logs**
  ```bash
  aws logs tail /ecs/zero-to-dev-dev-frontend --follow
  ```
  - [ ] Logs streaming
  - [ ] Nginx logs visible

### Application Update

- [ ] **Code change**
  - [ ] Make small change to API (e.g., health message)
  - [ ] Commit change

- [ ] **Redeploy**
  ```bash
  make aws-deploy
  ```
  - [ ] New images build
  - [ ] New images pushed
  - [ ] ECS tasks update (zero downtime)
  - [ ] New code deployed
  - [ ] Test endpoint shows change

### Scaling

- [ ] **Manual scale up**
  ```bash
  aws ecs update-service --cluster zero-to-dev-dev-cluster --service zero-to-dev-dev-api --desired-count 2
  ```
  - [ ] Service scales to 2 tasks
  - [ ] Both tasks healthy

- [ ] **Manual scale down**
  ```bash
  aws ecs update-service --cluster zero-to-dev-dev-cluster --service zero-to-dev-dev-api --desired-count 1
  ```
  - [ ] Service scales to 1 task
  - [ ] No downtime during scaling

### Cost Monitoring

- [ ] **Check costs**
  - [ ] AWS Console → Billing
  - [ ] Cost Explorer shows resources
  - [ ] Estimate ~$95/month
  - [ ] No unexpected charges

### Cleanup (Optional)

- [ ] **Destroy infrastructure**
  ```bash
  make aws-destroy
  ```
  - [ ] Terraform destroy plan shown
  - [ ] Type "yes" to confirm
  - [ ] All resources destroyed
  - [ ] ALB deleted
  - [ ] ECS tasks stopped
  - [ ] RDS deleted
  - [ ] ElastiCache deleted
  - [ ] VPC resources deleted
  - [ ] No errors

- [ ] **Verify deletion**
  - [ ] AWS Console → EC2 → Load Balancers (empty)
  - [ ] ECS → Clusters → Cluster empty or deleted
  - [ ] RDS → Databases (empty)

---

## CI/CD (GitHub Actions)

### Setup

- [ ] **GitHub Secrets configured**
  - [ ] `AWS_ACCESS_KEY_ID` added
  - [ ] `AWS_SECRET_ACCESS_KEY` added
  - [ ] See `docs/GITHUB_SETUP.md`

- [ ] **Workflows present**
  - [ ] `.github/workflows/deploy.yml` exists
  - [ ] `.github/workflows/pr-check.yml` exists

### PR Checks

- [ ] **Create test branch**
  ```bash
  git checkout -b test/ci-validation
  ```

- [ ] **Make small change**
  - [ ] Edit a file (e.g., README)
  - [ ] Commit and push

- [ ] **Open pull request**
  - [ ] Create PR on GitHub
  - [ ] Wait for checks to run

- [ ] **PR check workflow runs**
  - [ ] Workflow triggers automatically
  - [ ] Node.js setup succeeds
  - [ ] API dependencies install
  - [ ] Frontend dependencies install
  - [ ] Linting passes (or skips gracefully)
  - [ ] Docker Compose starts
  - [ ] Health checks pass
  - [ ] Workflow succeeds

### Deploy Workflow

- [ ] **Merge to main**
  - [ ] Merge PR or push to main

- [ ] **Deploy workflow runs**
  - [ ] Workflow triggers automatically
  - [ ] AWS credentials configure
  - [ ] ECR login succeeds
  - [ ] Frontend image builds
  - [ ] Frontend image pushes
  - [ ] API image builds
  - [ ] API image pushes
  - [ ] Terraform init succeeds
  - [ ] Terraform apply succeeds
  - [ ] ALB URL output shown
  - [ ] Workflow succeeds

- [ ] **Verify deployment**
  - [ ] Visit ALB URL
  - [ ] New code deployed
  - [ ] Application works

---

## Documentation

### Files Present

- [ ] `README.md` - Project overview
- [ ] `QUICKSTART.md` - 3-step setup
- [ ] `CONTRIBUTING.md` - Contribution guidelines
- [ ] `TROUBLESHOOTING.md` - Common issues
- [ ] `CHANGELOG.md` - Version history
- [ ] `LICENSE` - MIT license
- [ ] `docs/ARCHITECTURE.md` - System design
- [ ] `docs/DEVELOPER_GUIDE.md` - Development workflow
- [ ] `docs/AWS_DEPLOYMENT.md` - Cloud deployment
- [ ] `docs/GITHUB_SETUP.md` - CI/CD setup
- [ ] `docs/QA_CHECKLIST.md` - This file
- [ ] `infra/README.md` - Infrastructure docs
- [ ] `api/README.md` - API documentation
- [ ] `frontend/README.md` - Frontend documentation
- [ ] `scripts/cli/README.md` - CLI tools docs

### Documentation Quality

- [ ] **README.md**
  - [ ] Accurate project description
  - [ ] All badges working
  - [ ] Quick start section clear
  - [ ] Links work
  - [ ] Up to date

- [ ] **All code examples**
  - [ ] Run all commands
  - [ ] Verify they work
  - [ ] No errors

- [ ] **Screenshots/Diagrams**
  - [ ] Architecture diagram in docs
  - [ ] Images load correctly

- [ ] **Internal links**
  - [ ] All documentation links work
  - [ ] No 404 errors

---

## Security

### Secrets

- [ ] **No secrets in git**
  ```bash
  git log --all --full-history -- .env
  ```
  - [ ] No `.env` files in history

- [ ] **Search for passwords**
  ```bash
  git grep -i password
  ```
  - [ ] Only examples and docs
  - [ ] No real passwords

- [ ] **.gitignore complete**
  - [ ] `.env` listed
  - [ ] `terraform.tfvars` listed
  - [ ] `node_modules/` listed
  - [ ] `*.tfstate` listed

### IAM Policies

- [ ] **Principle of least privilege**
  - [ ] Reviewed `docs/github-actions-iam-policy.json`
  - [ ] Only required permissions
  - [ ] No wildcards unless necessary

### Security Groups

- [ ] **AWS security groups**
  - [ ] RDS not publicly accessible
  - [ ] ElastiCache not publicly accessible
  - [ ] ECS tasks allow only required ports
  - [ ] ALB allows only HTTP (port 80)

### Dependencies

- [ ] **No known vulnerabilities**
  ```bash
  cd api && npm audit
  cd frontend && npm audit
  ```
  - [ ] No high/critical vulnerabilities
  - [ ] Document any acceptable risks

---

## Performance

### Metrics

- [ ] **Setup time < 10 minutes**
  - [ ] Fresh clone to running environment
  - [ ] First-time setup
  - [ ] Timed and documented

- [ ] **Subsequent start < 2 minutes**
  - [ ] After `make down`
  - [ ] Run `make dev`
  - [ ] Timed

- [ ] **Hot reload < 3 seconds**
  - [ ] Frontend changes
  - [ ] API changes
  - [ ] Timed

- [ ] **API response time < 200ms**
  ```bash
  time curl http://localhost:4000/health
  ```
  - [ ] Average < 200ms

- [ ] **Frontend load time < 2 seconds**
  - [ ] Initial page load
  - [ ] Measured in browser DevTools

### Resource Usage

- [ ] **Docker resource usage**
  ```bash
  docker stats --no-stream
  ```
  - [ ] Total CPU < 50% (idle)
  - [ ] Total memory < 2GB
  - [ ] Reasonable resource usage

---

## Release Preparation

### Version

- [ ] **Update version numbers**
  - [ ] `package.json` (API)
  - [ ] `package.json` (Frontend)
  - [ ] Consistent across project

### Changelog

- [ ] **CHANGELOG.md updated**
  - [ ] New version entry
  - [ ] All changes listed
  - [ ] Date added
  - [ ] Links to issues/PRs

### Git Tag

- [ ] **Create tag**
  ```bash
  git tag -a v1.0.0 -m "Release v1.0.0: Zero-to-Running Developer Environment"
  ```
  - [ ] Tag created
  - [ ] Tag message clear

- [ ] **Push tag** (user action)
  ```bash
  git push origin v1.0.0
  ```

### GitHub Release

- [ ] **Create release on GitHub** (user action)
  - [ ] Release notes written
  - [ ] Features highlighted
  - [ ] Installation instructions
  - [ ] Known issues documented

---

## Final Verification

### Everything Works

- [ ] Local development ✅
- [ ] AWS deployment ✅
- [ ] CI/CD pipeline ✅
- [ ] Documentation complete ✅
- [ ] Security verified ✅
- [ ] Performance targets met ✅

### Ready for Release

- [ ] All checklist items completed
- [ ] No critical bugs
- [ ] Documentation reviewed
- [ ] Tested on multiple machines
- [ ] Ready to share with users

---

**📋 Checklist completed! Project is ready for v1.0.0 release! 🎉**

