# Architecture

## Overview

Zero-to-Running Developer Environment is a full-stack application demonstrating best practices for local development and cloud deployment. The architecture is designed for simplicity, scalability, and developer experience.

## System Architecture

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
│               ┌──────▼──────┐  ┌────▼─────┐         │     │
│               │   AWS RDS   │  │   AWS    │         │     │
│               │ PostgreSQL  │  │ElastiCache│        │     │
│               │             │  │  (Redis)  │         │     │
│               └─────────────┘  └──────────┘         │     │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack

### Frontend
- **React 18**: Modern UI library with hooks
- **TypeScript**: Type-safe JavaScript
- **Tailwind CSS**: Utility-first styling
- **Axios**: HTTP client for API communication

### Backend
- **Node.js 20**: JavaScript runtime
- **Express 4**: Minimalist web framework
- **TypeScript**: Type safety on the backend
- **node-postgres (pg)**: PostgreSQL client with connection pooling
- **ioredis**: High-performance Redis client

### Data Layer
- **PostgreSQL 16**: Relational database
- **Redis 7**: In-memory cache and session store

### Infrastructure
- **Local**: Docker Compose for orchestration
- **Cloud**: AWS ECS (Fargate), RDS, ElastiCache, ALB
- **IaC**: Terraform for infrastructure management
- **CI/CD**: GitHub Actions

## Service Communication

### Local Development
- Frontend `:3000` → API `:4000` via Docker network
- API → PostgreSQL `:5432` via Docker network
- API → Redis `:6379` via Docker network
- All services on `app-network` bridge network

### AWS Deployment
- Public → ALB → ECS Tasks
- ECS Tasks → RDS (private subnet)
- ECS Tasks → ElastiCache (private subnet)
- All traffic within VPC

## Key Design Decisions

### Monorepo Structure
All services in a single repository for:
- Simplified dependency management
- Atomic cross-service changes
- Single clone, single command setup
- Easier version control

### Docker Compose Over Kubernetes
For local development:
- Faster startup (no k8s overhead)
- Lower resource usage
- Simpler mental model
- Still uses containers (production parity)

### Health Checks
Multi-level health checking:
1. Docker container health
2. Application `/health` endpoints
3. Database connectivity checks
4. Cache connectivity checks

### Hot Reload
Development containers mount source code as volumes:
- Frontend: React dev server with hot module replacement
- Backend: nodemon watches for TypeScript changes
- No rebuild needed for code changes

## Data Flow

### Health Check Flow
```
1. Browser → Frontend :3000
2. Frontend → API :4000/health/all
3. API checks:
   - Self health
   - PostgreSQL connection
   - Redis connection
4. API returns aggregate status
5. Frontend displays status cards
```

### Typical API Request Flow
```
1. User interacts with React UI
2. Frontend makes Axios request to API
3. API validates request
4. API queries PostgreSQL (if needed)
5. API checks/updates Redis cache (if needed)
6. API returns JSON response
7. Frontend updates UI
```

## Scalability Patterns

### Local Development
- Limited by developer machine resources
- Optimized for fast iteration
- Single instance of each service

### AWS Deployment
- **Horizontal Scaling**: ECS auto-scaling (1-3 tasks)
- **Database Scaling**: RDS instance class upgrades, read replicas
- **Cache Scaling**: ElastiCache cluster mode
- **Load Balancing**: ALB distributes traffic

## Security Considerations

### Local Development
- Services isolated in Docker network
- Database password in .env (not committed)
- No external exposure except specified ports

### AWS Deployment
- VPC with public/private subnets
- Security groups with least privilege
- RDS in private subnet (no public access)
- ElastiCache in private subnet
- ECS task IAM roles
- ALB with HTTPS (future enhancement)

## Monitoring & Observability

### Local Development
- Docker Compose logs via `make logs`
- Health check endpoints
- Frontend health dashboard

### AWS Deployment
- CloudWatch Logs for ECS tasks
- ALB access logs
- RDS CloudWatch metrics
- Custom application metrics via health endpoints

## Development Workflow

### Local Development Flow

```
1. Developer runs `make dev`
2. Prerequisites checked
3. Docker Compose starts all services:
   - PostgreSQL initializes (10-15 seconds)
   - Redis starts (2-3 seconds)
   - API starts after dependencies ready
   - Frontend starts and connects to API
4. Health checks verify all services
5. Developer receives service URLs
6. Hot reload monitors for file changes
```

### Code Update Flow

```
1. Developer edits code
2. File watcher detects change
3. Frontend: Vite HMR updates browser (<2s)
   API: Nodemon restarts server (<3s)
4. Developer sees changes immediately
5. No container rebuild required
```

### Deployment Flow

```
1. Code pushed to GitHub
2. GitHub Actions triggered
3. Docker images built
4. Images pushed to ECR
5. Terraform updates task definitions
6. ECS performs rolling deployment
7. Old tasks drained
8. New tasks registered with ALB
9. Zero-downtime deployment complete
```

## Component Details

### Health Check System

The health check system provides multi-level monitoring:

**API Endpoints:**
- `/health` - Basic health (API running)
- `/health/db` - PostgreSQL connectivity
- `/health/cache` - Redis connectivity
- `/health/all` - Comprehensive system health

**Response Format:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-10T12:00:00.000Z",
  "services": {
    "api": { "status": "healthy" },
    "database": { "status": "healthy" },
    "cache": { "status": "healthy" }
  },
  "system": {
    "uptime": 3600,
    "memory": { "used": 512, "total": 2048 },
    "platform": "linux"
  }
}
```

### Database Migrations

Automatic migration system:
- Migrations stored in `api/src/db/migrations/`
- Tracking table: `migrations`
- Runs automatically on API startup
- Idempotent (safe to run multiple times)

### Connection Pooling

**PostgreSQL:**
- Min connections: 2
- Max connections: 10
- Idle timeout: 30 seconds
- Connection timeout: 5 seconds

**Redis:**
- Single connection with auto-reconnect
- Retry strategy: exponential backoff
- Max retries: 3

## Performance Characteristics

### Latency

| Operation | Local | AWS |
|-----------|-------|-----|
| Health check | <50ms | <200ms |
| Database query | <100ms | <150ms |
| Redis get/set | <10ms | <20ms |
| Frontend load | <1s | <2s |

### Throughput

- **API**: Can handle 1000+ req/s (single task)
- **Database**: Limited by instance size (db.t3.micro ~100 connections)
- **Redis**: 10,000+ ops/s
- **ALB**: Auto-scales with traffic

### Resource Usage

**Local Development:**
- CPU: 20-30% idle, 50-70% under load
- Memory: 1.5-2GB total
- Disk: ~500MB for images

**AWS Deployment:**
- ECS tasks: 256 CPU units, 512MB RAM per task
- RDS: db.t3.micro (1 vCPU, 1GB RAM)
- Redis: cache.t3.micro (1 vCPU, 500MB RAM)

## Disaster Recovery

### Local Environment

**Data Loss Prevention:**
- Database data persists in Docker volumes
- Survives `make down`
- Only deleted with `make clean`

**Recovery:**
```bash
# If services fail
make down
make dev

# If data corrupted
make clean
make dev
```

### AWS Environment

**Backup Strategy:**
- RDS automated backups (daily)
- Retention: 7 days
- Point-in-time recovery
- Snapshots before major changes

**Recovery:**
```bash
# Restore from backup via AWS Console
# or Terraform with snapshot ID
```

## Cost Optimization

### Development Environment

**Reduce costs by:**
- Using Fargate Spot (50-70% savings)
- Single availability zone
- Smaller instance types
- Scale to zero during off-hours
- Remove NAT Gateway (use bastion)

**Estimated savings:** ~$40-50/month

### Production Environment

**Recommended changes:**
- Multi-AZ for high availability
- Larger instance types as needed
- Enable ALB access logs
- Set up CloudWatch alarms
- Use Reserved Instances for predictable workloads

## Future Enhancements (Post v1.0)

### v1.1.0
- Authentication/Authorization (OAuth2, JWT)
- HTTPS support with ACM certificates
- Custom domain with Route53
- Advanced caching strategies
- Automated testing (unit + integration)

### v1.2.0
- Database migrations automation in CI/CD
- Distributed tracing with X-Ray
- Prometheus + Grafana monitoring
- Multi-region deployment
- CDN integration for frontend assets

### v2.0.0
- WebSocket support for real-time features
- Kubernetes/EKS deployment option
- Service mesh (Istio/App Mesh)
- Advanced security (WAF, GuardDuty)
- Multi-cloud support

