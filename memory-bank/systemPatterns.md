# System Patterns & Architecture

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL DEVELOPMENT                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Docker Compose Stack                                │   │
│  │                                                       │   │
│  │  ┌──────────┐      ┌──────────┐     ┌───────────┐  │   │
│  │  │ Frontend │ ───> │   API    │ ──> │ Postgres  │  │   │
│  │  │ React/TS │      │Express/TS│     │  (16.x)   │  │   │
│  │  │   :3000  │      │   :4000  │     │   :5432   │  │   │
│  │  └──────────┘      └────┬─────┘     └───────────┘  │   │
│  │                          │                           │   │
│  │                          └────────> ┌───────────┐   │   │
│  │                                     │   Redis   │   │   │
│  │                                     │   (7.x)   │   │   │
│  │                                     │   :6379   │   │   │
│  │                                     └───────────┘   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    AWS CLOUD DEPLOYMENT                       │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Application Load Balancer (Public)                  │   │
│  └────────┬──────────────────────────┬──────────────────┘   │
│           │                           │                       │
│    ┌──────▼──────┐           ┌───────▼──────┐               │
│    │ ECS Fargate │           │ ECS Fargate  │               │
│    │  Frontend   │           │     API      │               │
│    │  (React)    │           │  (Express)   │               │
│    └─────────────┘           └───────┬──────┘               │
│                                      │                       │
│                      ┌───────────────┼────────────────┐     │
│                      │               │                │     │
│               ┌──────▼──────┐  ┌────▼─────┐  ┌──────▼────┐ │
│               │   AWS RDS   │  │   AWS    │  │  Secrets  │ │
│               │ PostgreSQL  │  │ElastiCache│  │  Manager  │ │
│               │             │  │  (Redis)  │  │ (Removed) │ │
│               └─────────────┘  └──────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Key Technical Decisions

### 1. Monorepo Structure

**Decision:** Single repository with all services  
**Rationale:**
- Simplified dependency management
- Atomic changes across frontend/backend
- Single clone, single command setup
- Easier to maintain consistency

**Structure:**
```
/
├── api/              # Backend service
├── frontend/         # React frontend
├── infra/            # Terraform & AWS
├── scripts/          # CLI utilities
├── docs/             # Documentation
├── .github/          # CI/CD workflows
├── docker-compose.yml
├── Makefile
└── .env.example
```

### 2. Docker Compose for Local Development

**Decision:** Use Docker Compose instead of Kubernetes/minikube  
**Rationale:**
- Faster startup time
- Lower resource usage
- Easier for developers unfamiliar with k8s
- Still production-realistic (same containers)

**Key Features:**
- Health checks with `condition: service_healthy`
- Dependency ordering via `depends_on`
- Volume mounts for hot reload
- Named containers for easy debugging

### 3. Express.js for Backend

**Decision:** Express instead of NestJS, Fastify, or other frameworks  
**Rationale:**
- Most popular Node.js framework (familiar to most developers)
- Extensive ecosystem and middleware
- Simple, unopinionated
- Great TypeScript support

### 4. AWS ECS (Fargate) Over Kubernetes

**Decision:** ECS instead of GKE/EKS (from original PRD)  
**Rationale:**
- Simpler than Kubernetes
- Managed service (no control plane management)
- Lower cost for small workloads
- Better integration with AWS services (RDS, ElastiCache)

### 5. Mock Secrets (No AWS Secrets Manager)

**Decision:** Use `.env` files for secrets instead of AWS Secrets Manager  
**Rationale:**
- Original PRD: "Production-level secret management" is out of scope
- Simpler for local development
- Reduces AWS costs and complexity
- Demonstrates pattern without full implementation

### 6. Terraform for Infrastructure

**Decision:** Terraform instead of CloudFormation or CDK  
**Rationale:**
- Declarative and readable
- Provider-agnostic (could extend to other clouds)
- Large community and module ecosystem
- Better state management

### 7. Makefile for Command Interface

**Decision:** Makefile instead of npm scripts or custom CLI  
**Rationale:**
- Universal (works anywhere with `make`)
- Simple syntax for developers unfamiliar with tooling
- Built-in dependency management
- Industry standard for developer workflows

## Design Patterns

### Service Communication

**Pattern:** Direct service-to-service communication (no service mesh)  
**Implementation:**
- Local: Services communicate via Docker network
- AWS: Services communicate via private VPC networking
- Frontend calls API via public endpoint
- API connects to DB and Redis via internal endpoints

### Health Checks

**Pattern:** Multi-level health checks  
**Implementation:**
1. **Docker level:** Container health checks
2. **Application level:** `/health` endpoints
3. **Service level:** `/health/db`, `/health/cache` endpoints
4. **Aggregate:** `/health/all` comprehensive check

### Configuration Management

**Pattern:** Environment-based configuration  
**Implementation:**
- `.env` files for local development
- Environment variables in ECS task definitions
- No hardcoded values
- Smart defaults where possible

### Database Migrations

**Pattern:** Code-based migrations  
**Implementation:**
- SQL migration files in `/api/src/db/migrations/`
- Sequential numbering (001, 002, etc.)
- Migration runner tracks applied migrations
- Runs automatically on container startup

### Error Handling

**Pattern:** Centralized error middleware  
**Implementation:**
- Express error handling middleware
- Structured error responses
- Logging with correlation IDs
- User-friendly messages in CLI

## Component Relationships

### Frontend → API
- **Protocol:** HTTP/REST
- **Endpoint:** Configured via `REACT_APP_API_URL`
- **Authentication:** None (out of scope for v1.0)
- **Data Format:** JSON

### API → PostgreSQL
- **Protocol:** PostgreSQL wire protocol
- **Library:** `pg` (node-postgres)
- **Connection:** Connection pooling
- **Config:** `DATABASE_URL` environment variable

### API → Redis
- **Protocol:** Redis protocol
- **Library:** `ioredis`
- **Usage:** Caching, session storage (future)
- **Config:** `REDIS_URL` environment variable

### GitHub Actions → AWS
- **Authentication:** IAM credentials in GitHub Secrets
- **ECR:** Push Docker images
- **ECS:** Update task definitions and services
- **Terraform:** Apply infrastructure changes

## Scalability Considerations

### Local Development
- **Limitation:** Single machine, resource-constrained
- **Mitigation:** Lightweight Alpine images, volume mounts for hot reload

### AWS Deployment
- **ECS Auto-scaling:** 1-3 tasks based on CPU/memory
- **RDS:** Can upgrade instance class, add read replicas
- **ElastiCache:** Can upgrade node type, add cluster nodes
- **ALB:** Automatically scales to handle traffic

## Security Patterns

### Local Development
- Services isolated in Docker network
- No ports exposed except 3000, 4000, 5432, 6379
- .env excluded from git

### AWS Deployment
- **Network:** VPC with public/private subnets
- **Security Groups:** Least privilege access
- **IAM Roles:** Task-specific permissions
- **Encryption:** EBS encryption, transit encryption
- **No Secrets in Code:** Environment variables only

## Monitoring & Observability

### Local Development
- Docker Compose logs (`make logs`)
- Health check endpoints
- Status dashboard in frontend

### AWS Deployment
- CloudWatch Logs for all ECS tasks
- ALB access logs
- RDS CloudWatch metrics
- Custom metrics via API health endpoints

## Future Patterns (Post v1.0)

- **Service Mesh:** Potential Istio/App Mesh integration
- **Authentication:** OAuth2/JWT implementation
- **Caching Strategy:** Redis cache-aside pattern
- **Database Sharding:** Horizontal scaling strategy
- **Multi-region:** Cross-region replication

