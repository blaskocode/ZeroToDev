# Zero-to-Running Developer Environment

Get started in under 10 minutes.

## Overview

This project demonstrates a **zero-configuration, one-command solution** for setting up a complete development environment. Clone the repository, run a single command, and start coding immediately.

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
make dev      # Start local development environment
make down     # Stop all services
make logs     # View logs from all services
make clean    # Remove all containers and volumes
make status   # Show service status (coming in PR #6)
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
3. **View logs**: `make logs` (optional)
4. **Stop services**: `make down`

## AWS Deployment

Full AWS deployment instructions coming in PR #4.

```bash
make aws-bootstrap  # One-time setup
make aws-deploy     # Deploy to AWS
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System design and patterns *(coming in PR #1)*
- [Developer Guide](docs/DEVELOPER_GUIDE.md) - Detailed development workflow *(coming in PR #6)*
- [AWS Deployment](docs/AWS_DEPLOYMENT.md) - Cloud deployment guide *(coming in PR #4)*
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions *(coming in PR #7)*

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines *(coming in PR #7)*.

## License

MIT License - see [LICENSE](LICENSE) for details *(coming in PR #1)*.

## Support

For issues and questions:
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) *(coming in PR #7)*
2. Review [existing issues](../../issues)
3. Open a new issue with details

---

**Status**: PR #0 Complete - Foundation Established  
**Next**: PR #1 - Repository Scaffolding

