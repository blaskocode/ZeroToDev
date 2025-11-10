# Zero-to-Running Developer Environment (AWS Edition)

**Organization:** Wander  
**Project ID:** 3MCcAvCyK7F77BpbXUSI_1762376408364  

---

## 1. Executive Summary

The *Zero-to-Running Developer Environment* is an initiative by **Wander** to provide developers with a seamless, consistent, and production-realistic local development setup.  

This product allows any engineer to:
- Clone a repository,  
- Run a single command (`make dev`),  
- Instantly bring up a full multi-service stack (frontend, API, database, cache), locally or in the cloud.  

By standardizing the developer environment using **Docker Compose locally** and **AWS ECS (Fargate)** in the cloud, the system eliminates “works on my machine” issues and dramatically reduces onboarding friction.

---

## 2. Problem Statement

Developers often waste significant time configuring and debugging local environments. Inconsistent dependencies, tool versions, and service orchestration lead to onboarding delays and lost productivity.

This project solves that problem by enabling a one-command setup for both local and cloud environments. The goal is to maximize the time developers spend coding — not configuring.

---

## 3. Goals & Success Metrics

**Primary Goal:**  
Minimize the time and friction associated with environment setup and management.

**Success Metrics:**
- Setup time for new developers: **Under 10 minutes.**  
- Developer coding time vs setup time: **≥80% coding.**  
- Environment-related support tickets: **Reduced by 90%.**

---

## 4. Target Users & Personas

- **New Developer (Alex):** Needs to start coding immediately after cloning the repo.  
- **Ops-Savvy Engineer (Jamie):** Wants a configurable and repeatable dev environment aligned with production standards.

---

## 5. User Stories

1. As a **new developer**, I can run a single command to spin up my environment so I can start coding immediately.  
2. As a **developer**, I can tear down my environment easily to keep my local setup clean.  
3. As a **developer**, I can configure environment settings through a config file without editing core scripts.  
4. As a **developer**, I can deploy my environment to AWS with one command to ensure compatibility with cloud infra.  
5. As a **team**, I can verify each commit on `main` automatically deploys a working environment on AWS.

---

## 6. Functional Requirements

### P0: Must-have
- A single command (`make dev`) to start the full stack locally using **Docker Compose**.  
- Externalized configuration (YAML or `.env`) for service parameters.  
- Secure handling of secrets using **AWS Secrets Manager**.  
- Inter-service communication (API ↔ DB ↔ Redis).  
- Health checks for all services.  
- A single teardown command (`make down`) to cleanly remove containers.  
- Documentation guiding new developers from clone → running environment.  
- Automated **GitHub Actions** pipeline to deploy the environment to **AWS ECS Fargate** on merges to `main`.

### P1: Should-have
- Automatic dependency ordering (e.g., DB starts before API).  
- Clear, colorized CLI feedback with progress indicators and logs.  
- Developer-friendly defaults (hot reload, debug ports).  
- Graceful handling of missing dependencies or port conflicts.  
- Optional `make dev CLOUD=aws` flag for cloud deployment testing.

### P2: Nice-to-have
- Multiple environment profiles (`minimal`, `full-stack`).  
- Linting/pre-commit hooks for code quality.  
- Local HTTPS support for frontend.  
- Database seeding with sample data.  
- CLI themes (configurable colors, styles).

---

## 7. Non-Functional Requirements

- **Performance:** Environment setup under 10 minutes.  
- **Security:** Secrets stored in AWS Secrets Manager; `.env` files excluded from version control.  
- **Scalability:** Extendable to new services or environments.  
- **Availability:** Publicly reachable ECS environment for demonstration or QA.  
- **Compliance:** Uses standard, secure AWS infrastructure components.

---

## 8. System Architecture Overview

### Local Development
- **Docker Compose** orchestrates:
  - Frontend (React + Tailwind)
  - API (Node/Dora)
  - PostgreSQL (containerized)
  - Redis (containerized)
- Secrets loaded from `.env` file (or pulled from AWS Secrets Manager).

### Cloud Deployment (AWS)
- **AWS ECS (Fargate)** runs containers for frontend and backend.  
- **AWS RDS (PostgreSQL)** and **AWS ElastiCache (Redis)** for persistent managed data stores.  
- **AWS Secrets Manager** stores credentials and config values.  
- **GitHub Actions** automates build and deployment.

### Developer Workflow
- Local: `make dev` → Docker Compose up → ready in minutes.  
- Cloud: GitHub Actions deploys latest build to ECS → public endpoint accessible.  
- Each developer can create isolated ECS stacks prefixed with their name (e.g., `wander-dev-alex`).

---

## 9. User Experience
CLI focused with clear progress feedback and theme configurability.

---

## 10. Technical Requirements
Frontend React + Tailwind, Backend Node/TS, DB Postgres, Cache Redis, Docker, ECS Fargate, RDS, ElastiCache, Secrets Manager, GitHub Actions.

---

## 11. Dependencies & Assumptions
Developers have Docker, Make, Git, AWS CLI; AWS creds via Gauntlet AI; Terraform infra setup.

---

## 12. Out of Scope
Advanced CI/CD, multi-region, non-AWS clouds.

---

## 13. Future Enhancements
Dashboard UI, CodePipeline, metrics, additional service support.
