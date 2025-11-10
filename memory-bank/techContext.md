# Technical Context

## Technology Stack

### Frontend
- **React 18+** - UI framework
- **TypeScript 5+** - Type safety
- **Tailwind CSS 3+** - Styling framework
- **Axios** - HTTP client for API calls
- **Create React App** - Bootstrap tool (for quick setup)

### Backend
- **Node.js 20.x** - Runtime environment
- **Express 4.x** - Web framework
- **TypeScript 5+** - Type safety
- **pg (node-postgres)** - PostgreSQL client with connection pooling
- **ioredis** - Redis client
- **cors** - Cross-origin resource sharing
- **dotenv** - Environment variable management
- **nodemon** - Development hot reload
- **ts-node** - TypeScript execution

### Database & Cache
- **PostgreSQL 16** - Primary database
- **Redis 7** - Caching and session storage
- **Docker Images:**
  - `postgres:16-alpine` (local)
  - AWS RDS PostgreSQL 16 (cloud)
  - `redis:7-alpine` (local)
  - AWS ElastiCache Redis (cloud)

### Infrastructure
- **Docker 24+** - Containerization
- **Docker Compose 2+** - Local orchestration
- **Terraform 1.6+** - Infrastructure as Code
- **AWS Services:**
  - ECS (Fargate) - Container orchestration
  - ECR - Container registry
  - RDS - Managed PostgreSQL
  - ElastiCache - Managed Redis
  - ALB - Application Load Balancer
  - VPC - Networking
  - CloudWatch - Logging and monitoring
  - S3 - Terraform state storage
  - DynamoDB - Terraform state locking

### CI/CD
- **GitHub Actions** - CI/CD pipeline
- **GitHub Container Registry / ECR** - Image storage
- **Automated Workflows:**
  - PR checks (lint, build, test)
  - Deploy to ECS on merge to main

### Developer Tools
- **Make** - Command runner
- **Bash Scripts** - Automation
- **Node CLI Libraries:**
  - `chalk` - Colorized terminal output
  - `ora` - Progress spinners
  - `boxen` - Pretty message boxes
  - `figlet` - ASCII art banners

### Development Setup

#### Required Tools & Minimum Versions
```
- Docker >= 24.0
- Docker Compose >= 2.0
- Make >= 3.0
- Node.js >= 20.0
- npm >= 10.0
- Git >= 2.0
```

#### Optional Tools (for AWS deployment)
```
- AWS CLI >= 2.0
- Terraform >= 1.6
```

#### Editor/IDE Recommendations
- **VS Code** with extensions:
  - ESLint
  - Prettier
  - Docker
  - Terraform
  - GitLens

### Environment Configuration

#### Local Development (.env)
```bash
# Database
POSTGRES_USER=dev
POSTGRES_PASSWORD=devpass
POSTGRES_DB=appdb
DATABASE_URL=postgresql://dev:devpass@db:5432/appdb

# Redis
REDIS_URL=redis://redis:6379

# API
PORT=4000
NODE_ENV=development

# Frontend
REACT_APP_API_URL=http://localhost:4000
```

#### AWS Deployment (ECS Environment Variables)
```bash
# Database (from Terraform outputs)
DATABASE_URL=postgresql://user:pass@rds-endpoint:5432/appdb

# Redis (from Terraform outputs)
REDIS_URL=redis://elasticache-endpoint:6379

# API
PORT=4000
NODE_ENV=production

# Frontend
REACT_APP_API_URL=https://alb-url.us-east-1.elb.amazonaws.com
```

## Development Workflow

### Local Development Cycle

1. **Initial Setup** (one-time)
   ```bash
   # Install Node.js 20.x (via nvm recommended)
   nvm use
   
   # Copy environment file
   cp .env.example .env
   ```

2. **Daily Workflow**
   ```bash
   # Start all services
   make dev
   
   # In separate terminal: view logs
   make logs
   
   # Check service status
   make status
   
   # Stop all services
   make down
   ```

3. **Code Changes**
   - Frontend: Auto-reloads on file save
   - API: Nodemon restarts on file save
   - Database schema: Run migrations manually

### Project Structure

```
zero-to-dev/
├── api/                          # Backend service
│   ├── src/
│   │   ├── index.ts             # Express app entry point
│   │   ├── routes/              # Route handlers
│   │   │   └── health.routes.ts
│   │   ├── db/                  # Database logic
│   │   │   ├── postgres.ts
│   │   │   └── migrations/
│   │   │       └── 001_initial_schema.sql
│   │   ├── cache/               # Redis logic
│   │   │   └── redis.ts
│   │   ├── config/              # Configuration
│   │   │   └── env.ts
│   │   └── middleware/          # Express middleware
│   │       └── errorHandler.ts
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/                     # React frontend
│   ├── src/
│   │   ├── components/          # React components
│   │   │   ├── HealthStatus.tsx
│   │   │   └── ServiceCard.tsx
│   │   ├── services/            # API client logic
│   │   │   └── api.ts
│   │   ├── types/               # TypeScript types
│   │   │   └── health.types.ts
│   │   ├── theme/               # Theme configuration
│   │   │   └── config.ts
│   │   ├── App.tsx
│   │   └── index.tsx
│   ├── Dockerfile
│   ├── package.json
│   └── tailwind.config.js
│
├── infra/                        # Infrastructure code
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── backend.tf
│   │   └── modules/             # Terraform modules
│   │       ├── networking/
│   │       ├── ecr/
│   │       ├── ecs/
│   │       ├── rds/
│   │       ├── elasticache/
│   │       └── alb/
│   └── scripts/                 # Infrastructure scripts
│       ├── bootstrap-terraform.sh
│       └── deploy.sh
│
├── scripts/                      # Developer scripts
│   ├── cli/                     # CLI utilities
│   │   ├── lib/
│   │   │   ├── colors.js
│   │   │   ├── spinner.js
│   │   │   ├── logger.js
│   │   │   └── checks.js
│   │   └── package.json
│   ├── validate-prereqs.sh      # Prerequisites checker
│   ├── dev.sh                   # Enhanced dev startup
│   ├── down.sh                  # Shutdown script
│   └── status.sh                # Status dashboard
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md
│   ├── DEVELOPER_GUIDE.md
│   ├── AWS_DEPLOYMENT.md
│   ├── TROUBLESHOOTING.md
│   ├── GITHUB_SETUP.md
│   ├── QA_CHECKLIST.md
│   └── QUICKSTART.md
│
├── .github/
│   └── workflows/               # CI/CD pipelines
│       ├── deploy.yml           # Deploy to AWS
│       └── pr-check.yml         # PR validation
│
├── memory-bank/                  # Cursor Memory Bank
│   ├── projectbrief.md
│   ├── productContext.md
│   ├── systemPatterns.md
│   ├── techContext.md
│   ├── activeContext.md
│   └── progress.md
│
├── docker-compose.yml            # Local orchestration
├── Makefile                      # Command interface
├── .env.example                  # Environment template
├── .gitignore
├── .editorconfig
├── .nvmrc                        # Node version
├── README.md
└── LICENSE
```

## Technical Constraints

### Performance Targets
- Local startup: <10 minutes
- Hot reload: <3 seconds
- API response time: <200ms (p95)
- Frontend initial load: <2 seconds

### Resource Limits (Local)
- Database: 512MB RAM
- Redis: 256MB RAM
- API: 512MB RAM
- Frontend: 512MB RAM
- Total: ~2GB RAM for full stack

### AWS Instance Sizing
- **ECS Tasks:** 0.5 vCPU, 1GB RAM (Fargate)
- **RDS:** db.t3.micro (2 vCPU, 1GB RAM)
- **ElastiCache:** cache.t3.micro (2 vCPU, 0.5GB RAM)

### Cost Constraints
- Target: <$50/month for development environment
- Use smallest viable instance types
- Single AZ for dev (Multi-AZ for prod)

## Dependencies & Assumptions

### Developer Machine Requirements
- **OS:** macOS, Linux, or Windows with WSL2
- **RAM:** 8GB minimum (16GB recommended)
- **Disk:** 20GB free space
- **Network:** Stable internet for Docker image pulls

### AWS Account Requirements
- **Permissions:** Admin or PowerUser access
- **Regions:** us-east-1 (can be configured)
- **Service Limits:** Default limits sufficient

### Assumptions
- Developers have basic command-line knowledge
- Git and Docker Desktop installed
- AWS CLI configured (for cloud deployment)
- No corporate proxy blocking Docker Hub

## Known Technical Debt

None yet - project is in planning phase. This section will track technical debt as it accrues during implementation.

## Future Technical Enhancements

- **Testing:** Jest unit tests, Playwright E2E tests
- **Linting:** ESLint + Prettier pre-commit hooks
- **Type Safety:** Shared types between frontend/backend
- **Monitoring:** Prometheus + Grafana
- **Logging:** Structured JSON logging
- **Security Scanning:** Snyk or similar
- **Performance:** CDN for frontend assets
- **Database:** Read replicas, connection pooling optimization

