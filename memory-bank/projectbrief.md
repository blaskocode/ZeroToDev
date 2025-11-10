# Project Brief: Zero-to-Running Developer Environment

**Organization:** Wander  
**Project ID:** 3MCcAvCyK7F77BpbXUSI_1762376408364  
**Status:** Planning Phase  
**Start Date:** November 10, 2025

---

## Overview

The Zero-to-Running Developer Environment is a solution that enables developers to clone a repository, run a single command (`make dev`), and instantly have a fully functional multi-service application environment running locally or in the cloud.

## Core Problem

Developers waste significant time configuring and debugging local environments. Inconsistent dependencies, tool versions, and service orchestration lead to onboarding delays, "works on my machine" issues, and lost productivity.

## Solution

A standardized developer environment using:
- **Local:** Docker Compose for instant multi-service setup
- **Cloud:** AWS ECS (Fargate) for production-realistic deployment
- **Automation:** Single-command setup with comprehensive health checks

## Primary Goal

Minimize time and friction associated with environment setup and management, enabling developers to spend 80%+ of their time coding rather than configuring.

## Success Metrics

1. **Setup time:** Under 10 minutes from clone to coding
2. **Coding time:** ≥80% time spent coding vs. managing infrastructure
3. **Support reduction:** 90% decrease in environment-related support tickets

## Key Constraints

- Must work on macOS, Linux, and Windows
- No production-level secrets management (use mock `.env` files)
- Keep infrastructure costs minimal (t3.micro instances)
- Single command for setup, single command for teardown

## Technology Stack

**Frontend:** React, TypeScript, Tailwind CSS  
**Backend:** Node.js, Express, TypeScript  
**Database:** PostgreSQL 16  
**Cache:** Redis 7  
**Local Orchestration:** Docker Compose  
**Cloud Platform:** AWS (ECS Fargate, RDS, ElastiCache)  
**Infrastructure:** Terraform  
**CI/CD:** GitHub Actions

## Target Users

1. **New Developer (Alex):** Fresh hire who needs to start coding immediately without manual setup hassles
2. **Ops-Savvy Engineer (Jamie):** Experienced developer looking for streamlined, configurable processes aligned with production standards

## Out of Scope

- Advanced CI/CD features beyond basic deployment
- Production-level secret management systems (AWS Secrets Manager removed from plan)
- Multi-region deployments
- Non-AWS cloud providers
- Kubernetes/GKE deployment (AWS ECS chosen instead)

## Implementation Approach

8 sequential Pull Requests (PRs):
- PR #0: Git setup & prerequisites
- PR #1: Repository scaffolding
- PR #2: Backend API (Express)
- PR #3: Frontend (React)
- PR #4: Infrastructure (Terraform/AWS)
- PR #5: CI/CD (GitHub Actions)
- PR #6: Developer experience & CLI
- PR #7: Documentation & QA

## Critical Success Factors

1. Complete automation - no manual configuration steps
2. Clear, helpful error messages and documentation
3. Fast startup time (<10 minutes)
4. Production-realistic cloud environment
5. Comprehensive health checks for all services

