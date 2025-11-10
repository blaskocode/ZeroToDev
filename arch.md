# Architecture Diagram

```mermaid
flowchart TD

subgraph Local["🧑‍💻 Local Developer Environment (make dev)"]
    A1[Developer Clone Repo] --> A2[Run make dev]
    A2 --> A3[Docker Compose Up]
    subgraph Compose["Docker Compose Stack"]
        FE[Frontend (React + Tailwind)] --> API[Backend API (Node/Dora)]
        API --> DB[(PostgreSQL Container)]
        API --> REDIS[(Redis Container)]
    end
    A3 --> A4[CLI Feedback: Logs + Health Checks]
    A4 --> A5[Ready to Code in <10 min]
end

subgraph Cloud["☁️ AWS Cloud Deployment (GitHub Actions → ECS)"]
    B1[Merge to main Branch] --> B2[GitHub Actions CI/CD Pipeline]
    B2 --> B3[Build Docker Images]
    B3 --> B4[Push to ECR (Elastic Container Registry)]
    B4 --> B5[Deploy to ECS (Fargate)]
    subgraph ECS["ECS Task (Fargate)"]
        FE_AWS[Frontend (React)] --> API_AWS[Backend (Node/Dora)]
        API_AWS --> RDS[(AWS RDS: PostgreSQL)]
        API_AWS --> ECACHE[(AWS ElastiCache: Redis)]
    end
    B5 --> B6[App Load Balancer (Public URL)]
    B6 --> B7[Developer Access via Public Endpoint]
    subgraph Secrets["🔐 AWS Secrets Manager"]
        SEC1[DB Credentials]
        SEC2[Redis Config]
        SEC3[API Keys / Env Vars]
    end
    Secrets --> ECS
end

Local -.->|Optional make dev CLOUD=aws| Cloud
Local -.->|Pulls Secrets from| Secrets
```
