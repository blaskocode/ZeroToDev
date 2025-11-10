# Product Context

## Why This Project Exists

Developers consistently face friction when setting up local development environments:
- Hours spent debugging dependency conflicts
- Version mismatches between team members
- "Works on my machine" syndrome
- Complex multi-service orchestration
- Steep learning curve for new team members
- Lost productivity troubleshooting infrastructure instead of coding

This project eliminates these problems by providing a **zero-configuration, one-command solution** that gets developers coding in under 10 minutes.

## Problems It Solves

### For New Developers
- **Problem:** Spending first day/week setting up environment instead of contributing
- **Solution:** Clone repo → `make dev` → start coding in <10 minutes

### For Engineering Teams
- **Problem:** Inconsistent environments causing bugs and integration issues
- **Solution:** Everyone runs identical Docker-based environments

### For Ops/DevOps
- **Problem:** Maintaining separate local and production configurations
- **Solution:** Local Docker Compose mirrors AWS ECS production architecture

### For Organizations
- **Problem:** High cost of environment-related support and onboarding
- **Solution:** 90% reduction in support tickets, faster developer ramp-up

## How It Should Work

### Local Development Workflow

1. **Clone & Setup** (1 minute)
   ```bash
   git clone <repo>
   cd zero-to-dev
   cp .env.example .env
   ```

2. **Prerequisites Check** (1 minute)
   ```bash
   ./scripts/validate-prereqs.sh
   # Automatically checks Docker, Make, Node.js, etc.
   ```

3. **Start Environment** (5-8 minutes)
   ```bash
   make dev
   # Brings up: Frontend, API, PostgreSQL, Redis
   # Shows colorized progress with health checks
   # Displays success message with URLs
   ```

4. **Code** (all remaining time!)
   - Hot reload for frontend changes
   - Hot reload for API changes
   - Access services at localhost:3000 (frontend), localhost:4000 (API)

5. **Teardown** (30 seconds)
   ```bash
   make down
   ```

### Cloud Deployment Workflow

1. **One-time AWS Setup**
   ```bash
   make aws-bootstrap
   # Creates Terraform state backend (S3 + DynamoDB)
   ```

2. **Deploy to AWS**
   ```bash
   make aws-deploy
   # Builds Docker images
   # Pushes to ECR
   # Provisions ECS, RDS, ElastiCache, ALB
   # Outputs public ALB URL
   ```

3. **Automatic CI/CD**
   - Merge to `main` → GitHub Actions triggers
   - Builds images → Pushes to ECR → Updates ECS tasks
   - Public endpoint accessible for demos/QA

## User Experience Goals

### Simplicity
- **Single command** for every major operation
- **No configuration files** to manually edit (use .env with smart defaults)
- **Clear visual feedback** during all operations

### Speed
- **Under 10 minutes** from clone to running environment
- **Instant hot reload** for code changes
- **Fast teardown** and cleanup

### Reliability
- **Health checks** verify all services before declaring success
- **Dependency ordering** ensures database starts before API
- **Helpful error messages** with actionable solutions

### Transparency
- **Colorized logs** show what's happening
- **Progress indicators** for long operations
- **Status dashboard** shows service health in real-time

### Accessibility
- Works on **macOS, Linux, Windows**
- **Comprehensive documentation** for all experience levels
- **Troubleshooting guide** for common issues

## User Journeys

### Alex (New Developer) - First Day

**Goal:** Start contributing to codebase on day one

**Journey:**
1. Receives repo link in welcome email
2. Clones repo, runs `make dev`
3. Sees colorful CLI output with progress
4. Gets "Ready to code!" message in 8 minutes
5. Opens http://localhost:3000, sees running app
6. Makes first code change, sees hot reload work
7. Submits first PR same day

**Success:** Alex feels productive and confident immediately

### Jamie (Senior Engineer) - New Project

**Goal:** Deploy team's new service to AWS for QA review

**Journey:**
1. Clones repo, verifies local setup with `make dev`
2. Reviews infrastructure code in `/infra/terraform`
3. Runs `make aws-bootstrap` (one-time setup)
4. Runs `make aws-deploy`, waits 15 minutes
5. Gets ALB URL, shares with QA team
6. QA tests on real AWS infrastructure
7. Merges to main, CI/CD auto-deploys future changes

**Success:** Jamie can focus on business logic, not infrastructure management

## Key Differentiators

1. **Production-Realistic Local Environment** - Not just mocks; real PostgreSQL and Redis
2. **Cloud Parity** - Local Docker Compose mirrors AWS ECS architecture
3. **Automated Everything** - No manual steps from clone to deployment
4. **Developer Experience First** - Beautiful CLI, helpful errors, comprehensive docs
5. **Cost Conscious** - Uses minimal AWS resources (t3.micro instances)

