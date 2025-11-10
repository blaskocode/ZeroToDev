# Zero-to-Running Developer Environment

> **Clone → Run → Code** in under 10 minutes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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

- **Frontend**: http://localhost:3000
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

Full AWS deployment instructions coming in PR #4.

```bash
make aws-bootstrap  # One-time setup
make aws-deploy     # Deploy to AWS
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and patterns
- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Detailed development workflow *(coming in PR #6)*
- [AWS Deployment](docs/AWS_DEPLOYMENT.md) - Cloud deployment guide *(coming in PR #4)*
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions *(coming in PR #7)*

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines *(coming in PR #7)*.

## Project Status

| Phase | Status | Notes |
|-------|--------|-------|
| ✅ PR #0: Git Setup | Complete | Repository initialized |
| 🟢 PR #1: Scaffolding | In Progress | Structure and orchestration |
| ⏸️ PR #2: Backend API | Pending | Express + TypeScript |
| ⏸️ PR #3: Frontend | Pending | React + Tailwind |
| ⏸️ PR #4: Infrastructure | Pending | Terraform + AWS |
| ⏸️ PR #5: CI/CD | Pending | GitHub Actions |
| ⏸️ PR #6: Developer UX | Pending | CLI enhancements |
| ⏸️ PR #7: Documentation | Pending | Comprehensive docs |

## Roadmap

### Current: PR #1 - Repository Scaffolding
- [x] Directory structure
- [x] Docker Compose configuration
- [x] Makefile with commands
- [x] Environment configuration
- [x] Initial documentation

### Next: PR #2 - Backend API
- Express.js + TypeScript server
- Health check endpoints
- PostgreSQL integration
- Redis integration
- Database migrations

### Future: PR #3-7
See [tasks.md](tasks.md) for detailed breakdown.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines *(coming in PR #7)*.

## Support

For issues and questions:
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) *(coming in PR #7)*
2. Review [existing issues](../../issues)
3. Open a new issue with details

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ by the Wander team**

