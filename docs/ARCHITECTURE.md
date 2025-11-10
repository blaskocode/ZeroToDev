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

## Future Enhancements (Post v1.0)

- Authentication/Authorization (OAuth2, JWT)
- Advanced caching strategies
- Database migrations automation
- Distributed tracing
- Prometheus + Grafana monitoring
- Multi-region deployment
- CDN integration for frontend assets
- WebSocket support for real-time features

