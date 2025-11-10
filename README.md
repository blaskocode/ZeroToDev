# Zero-to-Running Developer Environment

> **Clone → Run → Code** in under 10 minutes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Deploy to AWS ECS](https://github.com/YOUR_USERNAME/ZeroToDev/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/ZeroToDev/actions/workflows/deploy.yml)
[![PR Checks](https://github.com/YOUR_USERNAME/ZeroToDev/actions/workflows/pr-check.yml/badge.svg)](https://github.com/YOUR_USERNAME/ZeroToDev/actions/workflows/pr-check.yml)

## Overview

This project demonstrates a **zero-configuration, one-command solution** for setting up a complete, production-realistic development environment. No manual setup, no configuration hassles—just instant productivity.

**Built for**:
- 🆕 New developers who need to start coding on day one
- 🏗️ Teams standardizing their development environments  
- 🎓 Learning modern full-stack development patterns
- ☁️ Organizations needing local-to-cloud parity

Clone the repository, run a single command, and start coding immediately.

## Features

- 🚀 **Instant Setup** - From clone to coding in under 10 minutes
- 🐳 **Docker-Based** - Consistent environments across all machines
- 🔄 **Hot Reload** - Real-time code updates for frontend and backend
- 🏥 **Health Monitoring** - Built-in service health dashboard
- 🎨 **Beautiful CLI** - Colorized output with progress indicators and helpful error messages
- ☁️ **Cloud Ready** - One-command deployment to AWS
- 📚 **Comprehensive Docs** - Clear guides for all scenarios

## Prerequisites

Run the prerequisites validation script to check your system:

```bash
./scripts/validate-prereqs.sh
```

### Required Tools

- **Docker** >= 24.0
- **Docker Compose** >= 2.0
- **Make** >= 3.0
- **Node.js** >= 20.0
- **npm** >= 10.0
- **Git** >= 2.0

### Optional Tools (for AWS deployment)

- **AWS CLI** >= 2.0
- **Terraform** >= 1.6

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ZeroToDev
cp .env.example .env
```

### 2. Validate Prerequisites

```bash
./scripts/validate-prereqs.sh
```

### 3. Start Development Environment

```bash
make dev
```

### 4. Access Services

- **Frontend**: http://localhost:5173
- **API**: http://localhost:4000
- **API Health Check**: http://localhost:4000/health

## Available Commands

```bash
make help     # Show all available commands
make prereqs  # Validate prerequisites
make dev      # Start local development environment
make down     # Stop all services
make logs     # View logs from all services
make status   # Show service status
make clean    # Remove all containers and volumes

# AWS deployment (coming in PR #4)
make aws-bootstrap  # One-time AWS setup
make aws-plan       # Preview infrastructure changes
make aws-deploy     # Deploy to AWS
make aws-destroy    # Tear down AWS infrastructure
```

## Project Structure

```
/
├── api/              # Backend service (Express + TypeScript)
├── frontend/         # React frontend (TypeScript + Tailwind)
├── infra/            # Terraform infrastructure code
├── scripts/          # CLI utilities and helper scripts
├── docs/             # Documentation
├── memory-bank/      # Project context and history
├── .github/          # CI/CD workflows
├── docker-compose.yml
├── Makefile
└── .env.example
```

## Technology Stack

- **Frontend**: React, TypeScript, Tailwind CSS
- **Backend**: Node.js, Express, TypeScript
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Local**: Docker Compose
- **Cloud**: AWS (ECS, RDS, ElastiCache)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions

## Development Workflow

1. **Start services**: `make dev`
2. **Make code changes** - Hot reload handles updates automatically  
   - Frontend changes reflect immediately
   - Backend changes auto-restart the server
3. **View logs**: `make logs` (in separate terminal)
4. **Check status**: `make status`
5. **Stop services**: `make down`

### Tips for Effective Development

- **First time?** Run `make prereqs` to validate your setup
- **Port conflicts?** Check `docker-compose.yml` to change port mappings
- **Clean start?** Use `make clean` to reset everything
- **Database access?** Connect to `localhost:5432` with credentials from `.env`
- **Redis CLI?** Run `docker exec -it zero-to-dev-redis redis-cli`

## AWS Deployment

Deploy to AWS with a single command. See [AWS Deployment Guide](docs/AWS_DEPLOYMENT.md) for details.

```bash
# One-time setup
make aws-bootstrap

# Deploy to AWS
make aws-deploy

# View deployment status
make aws-outputs
```

## Documentation

- **[Quick Start](QUICKSTART.md)** - Get running in 3 steps
- **[Architecture](docs/ARCHITECTURE.md)** - System design and patterns
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Detailed development workflow
- **[AWS Deployment](docs/AWS_DEPLOYMENT.md)** - Cloud deployment guide
- **[GitHub Setup](docs/GITHUB_SETUP.md)** - CI/CD configuration
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing](CONTRIBUTING.md)** - Contribution guidelines
- **[Changelog](CHANGELOG.md)** - Version history

## Project Status

| Phase | Status | Notes |
|-------|--------|-------|
| ✅ PR #0: Git Setup | Complete | Repository initialized |
| ✅ PR #1: Scaffolding | Complete | Structure and orchestration |
| ✅ PR #2: Backend API | Complete | Express + TypeScript + PostgreSQL + Redis |
| ✅ PR #3: Frontend | Complete | React + Vite + Tailwind CSS |
| ✅ PR #4: Infrastructure | Complete | Terraform + AWS ECS |
| ✅ PR #5: CI/CD | Complete | GitHub Actions pipeline |
| ✅ PR #6: Developer UX | Complete | Enhanced CLI with colors |
| 🟢 PR #7: Documentation | In Progress | Final docs and QA |

**🎉 Project is feature-complete and ready for v1.0.0 release!**

## What's Included

### ✨ Local Development Environment
- **One Command Setup**: `make dev` starts everything
- **Full Stack**: React frontend + Express API + PostgreSQL + Redis
- **Hot Reload**: Instant code updates without rebuilds
- **Health Dashboard**: Real-time service monitoring
- **Beautiful CLI**: Colorized output with progress indicators
- **Fast**: Setup completes in under 10 minutes

### ☁️ Cloud Deployment
- **AWS Infrastructure**: Complete Terraform setup
- **Production Ready**: ECS (Fargate), RDS, ElastiCache, ALB
- **Auto-Scaling**: Handles traffic spikes automatically
- **Monitoring**: CloudWatch logs and metrics
- **CI/CD**: GitHub Actions for automated deployments

### 📚 Comprehensive Documentation
- **Quick Start Guide**: Get running in 3 steps
- **Developer Guide**: Detailed workflow and tips
- **AWS Deployment**: Step-by-step cloud setup
- **Troubleshooting**: Solutions to common issues
- **Architecture Docs**: System design and patterns

## Performance Targets

- ⚡ **Setup Time**: Under 10 minutes from clone to coding
- 💻 **Coding Time**: 80%+ time spent coding vs. infrastructure
- 🎫 **Support Reduction**: 90% fewer environment-related issues

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Support

For issues and questions:
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review [Developer Guide](docs/DEVELOPER_GUIDE.md)
3. Review [existing issues](../../issues)
4. Open a new issue with complete details

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ by the Wander team**

