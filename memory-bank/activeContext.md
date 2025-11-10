# Active Context

**Last Updated:** November 10, 2025  
**Current Phase:** Implementation - PR #0 In Progress  
**Active PR:** PR #0 - Git Repository Setup & Prerequisites Validation (90% complete)

---

## Current Work Focus

### What We're Working On
**PR #0: Git Repository Setup & Prerequisites Validation** - 90% complete. All files created, waiting for user to run git commands.

### Recent Changes
1. **PR #0 Implementation Started** - Created all foundation files:
   - `.gitignore` with comprehensive exclusions
   - `.editorconfig` for consistent code formatting
   - `.nvmrc` specifying Node.js 20.11.0
   - `scripts/validate-prereqs.sh` with colorized output and version checking
   - `README.md` with quick start instructions
2. **Analyzed original PRD** - Identified discrepancy between original (GKE/Kubernetes) and working plan (AWS ECS)
2. **Clarified architecture decision** - Chose AWS + ECS over GKE based on user preference
3. **Removed AWS Secrets Manager** - Using mock `.env` secrets as per original PRD scope
4. **Clarified backend framework** - Confirmed Express.js (not "Dora")
5. **Created comprehensive task breakdown** - 8 PRs from setup to release
6. **Added missing components:**
   - Git repository initialization (PR #0)
   - Complete Docker Compose service definitions
   - Database migrations
   - Prerequisites validation
   - Enhanced CLI with progress indicators
   - Comprehensive documentation plan
7. **Initialized memory bank** - All core files created with complete context
8. **Read and applied cursor rules** - Workflow rules, file limits, security scanning, task management

### Current Decisions & Considerations

#### ✅ Decided
- **Cloud Platform:** AWS ECS (Fargate) - confirmed with user
- **Backend Framework:** Express.js - simple, popular, well-documented
- **Secrets Management:** Mock `.env` files - no AWS Secrets Manager
- **Repository Structure:** Monorepo with all services
- **Development Approach:** 8 sequential PRs

#### 🤔 Pending Decisions
None - all major architectural decisions have been made.

#### 🚧 Current Blockers
None - awaiting user to run git commands (git init, git commit) as per workspace rules.

### Active Cursor Rules

The following cursor rules are now in effect and must be followed:

1. **🚨 No Git Commands** - NEVER run git commands (user handles all git operations)
2. **📋 Task List Source of Truth** - `tasks.md` is the official task list; consult before work, update after completion
3. **💾 Memory Bank Updates** - Update memory bank after EVERY prompt, show confirmation message
4. **📏 750-Line File Limit** - Application files must not exceed 750 lines; split if approaching limit
5. **🔒 Security Scanning** - All generated code must be scanned with Semgrep before completion
6. **⏸️ One Task at a Time** - Complete one sub-task, wait for user approval, then proceed to next
7. **🎯 Yoda Quotes** - End every response with a Yoda-style inspirational quote

---

## Next Steps

### Immediate (PR #0 - Git Setup) - 90% COMPLETE
1. ~~Initialize Git repository~~ → USER MUST RUN: `git init && git branch -M main`
2. ✅ Create `.gitignore` with comprehensive exclusions
3. ✅ Add `.editorconfig` for consistent formatting
4. ✅ Create `.nvmrc` specifying Node 20.11.0
5. ✅ Build prerequisites validation script (`scripts/validate-prereqs.sh`)
6. ✅ Create initial README with quick start instructions
7. ~~Make initial commit~~ → USER MUST RUN: `git add . && git commit -m "Initial commit: project setup and prerequisites validation"`

### Short-term (PR #1-3)
1. **PR #1:** Repository scaffolding
   - Create monorepo structure
   - Add complete docker-compose.yml with health checks
   - Create Makefile with all commands
   - Add comprehensive .env.example

2. **PR #2:** Backend API setup
   - Initialize Express.js + TypeScript project
   - Implement health check endpoints
   - Add PostgreSQL connector with connection pooling
   - Add Redis connector
   - Create initial database migration
   - Build Dockerfile with multi-stage build

3. **PR #3:** Frontend setup
   - Bootstrap React + TypeScript app
   - Configure Tailwind CSS
   - Build health status dashboard components
   - Implement real-time polling (5-second interval)
   - Add theme toggle (light/dark mode)
   - Create Dockerfile

### Medium-term (PR #4-5)
4. **PR #4:** Infrastructure as Code
   - Create Terraform modules (VPC, ECR, ECS, RDS, ElastiCache, ALB)
   - Build bootstrap script for Terraform backend
   - Add deployment script
   - Document AWS setup process

5. **PR #5:** CI/CD Pipeline
   - Create GitHub Actions workflow for deployment
   - Add PR validation workflow
   - Document GitHub Secrets setup
   - Test full pipeline end-to-end

### Long-term (PR #6-7)
6. **PR #6:** Developer Experience
   - Build CLI utilities with chalk, ora, boxen
   - Create enhanced startup script with progress indicators
   - Add status dashboard script
   - Implement helpful error messages
   - Write comprehensive developer guide

7. **PR #7:** Documentation & QA
   - Write all documentation files
   - Create QA checklist
   - Perform end-to-end testing
   - Measure performance against targets
   - Tag v1.0.0 release

---

## Active Questions & Answers

### Q: Why AWS ECS instead of Kubernetes (original PRD mentioned GKE)?
**A:** User preference. ECS is simpler, more managed, and better integrated with AWS services. Original PRD had GKE, but user chose AWS ECS for this implementation.

### Q: What does "Node/Dora" mean in the original PRD?
**A:** Likely means "Node.js or Dora API" where Dora was a placeholder. User confirmed we should use Express.js.

### Q: Why not use AWS Secrets Manager?
**A:** Original PRD states "Production-level secret management systems" is out of scope. Mock `.env` files are sufficient for this project's goals.

### Q: Will this be a working, deployed app after following all PRs?
**A:** Yes! The plan produces:
- ✅ Fully functional local development environment
- ✅ Complete AWS cloud deployment
- ✅ Automated CI/CD pipeline
- ✅ Health monitoring dashboard
- ✅ Comprehensive documentation
- ✅ Setup time under 10 minutes

---

## Context for Next Session

When I return after a memory reset, I should know:

1. **Project Status:** Ready to begin implementation (PR #0)
2. **Key Decisions:** AWS ECS chosen, Express.js confirmed, no Secrets Manager
3. **Implementation Plan:** 8 sequential PRs documented in `/tasks.md`
4. **Success Criteria:** <10 min setup, 80%+ coding time, 90% support reduction
5. **Technology Stack:** React/TypeScript frontend, Express/TypeScript API, PostgreSQL, Redis, Docker Compose local, AWS ECS cloud
6. **No Blockers:** All clarifications complete, ready to code

### Files to Reference
- **Implementation plan:** `/tasks.md` (complete PR breakdown)
- **Original requirements:** `/PRD_Wander_ZerotoRunning_Developer_Environment.md`
- **Refined requirements:** `/PRD.md`
- **Architecture:** `/arch.md`
- **Memory Bank:** `/memory-bank/*.md` (this directory)

### What to Do Next
Start implementing **PR #0: Git Repository Setup & Prerequisites Validation** following the detailed task list in `/tasks.md`.

