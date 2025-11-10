# Quick Start Guide

Get from clone to coding in under 10 minutes.

## Prerequisites

Before starting, ensure you have these tools installed:

- **Docker** (>= 24.0) & **Docker Compose** (>= 2.0)
- **Make** (>= 3.0)
- **Node.js** (>= 20.0) & **npm** (>= 10.0)
- **Git** (>= 2.0)

> **Tip**: Run `./scripts/validate-prereqs.sh` to check your system.

## Three-Step Setup

### Step 1: Clone and Configure

```bash
# Clone the repository
git clone <repository-url>
cd ZeroToDev

# Copy environment variables
cp .env.example .env
```

### Step 2: Validate Prerequisites

```bash
./scripts/validate-prereqs.sh
```

This script will check:
- ✅ Docker and Docker Compose versions
- ✅ Node.js and npm versions
- ✅ Make and Git availability
- ⚠️ Optional tools (AWS CLI, Terraform)

### Step 3: Start Development Environment

```bash
make dev
```

This single command will:
1. 🐳 Build Docker images for frontend and API
2. 🚀 Start PostgreSQL, Redis, API, and Frontend
3. 🏥 Run health checks for all services
4. ✨ Display service URLs

**Expected output:**
```
✅ Prerequisites check passed
🐳 Starting Docker Compose...
✅ PostgreSQL is healthy
✅ Redis is healthy
✅ API is healthy (http://localhost:4000)
✅ Frontend is healthy (http://localhost:5173)

🎉 All services are running!

Services:
  Frontend: http://localhost:5173
  API:      http://localhost:4000
  Health:   http://localhost:4000/health
```

## Access Your Environment

Once setup completes, access:

- **Frontend Dashboard**: http://localhost:5173
- **API Health Check**: http://localhost:4000/health
- **Database**: `localhost:5432` (credentials in `.env`)
- **Redis**: `localhost:6379`

## What's Next?

### Start Coding

1. **Frontend changes**: Edit files in `frontend/src/` - hot reload is enabled
2. **API changes**: Edit files in `api/src/` - nodemon auto-restarts the server
3. **View logs**: Run `make logs` in a separate terminal

### Check Service Status

```bash
make status
```

Shows:
- Service health status
- Resource usage
- Port mappings
- Recent logs

### Stop Services

```bash
make down
```

Gracefully stops all containers.

### Clean Everything

```bash
make clean
```

Removes all containers, volumes, and cached data. Use for a fresh start.

## Common Commands

```bash
make help     # Show all available commands
make prereqs  # Validate prerequisites
make dev      # Start local environment
make down     # Stop all services
make logs     # View logs from all services
make status   # Show service status dashboard
make clean    # Remove all containers and volumes
```

## Troubleshooting

### Docker Not Running

**Error**: `Cannot connect to the Docker daemon`

**Solution**: Start Docker Desktop or run `sudo systemctl start docker` (Linux)

### Port Already in Use

**Error**: `port is already allocated`

**Solution**: 
1. Check what's using the port: `lsof -i :5173` (or :4000, :5432, :6379)
2. Stop the conflicting service
3. Or edit `docker-compose.yml` to use different ports

### Services Not Starting

**Error**: Services fail health checks

**Solution**:
```bash
# View detailed logs
make logs

# Clean and restart
make clean
make dev
```

### Node Version Mismatch

**Error**: `The engine "node" is incompatible`

**Solution**: 
```bash
# If you use nvm
nvm install 20
nvm use 20

# Verify version
node --version
```

## Next Steps

- Read the [Developer Guide](docs/DEVELOPER_GUIDE.md) for detailed workflow
- Check [Architecture Docs](docs/ARCHITECTURE.md) to understand the system
- See [Troubleshooting](docs/TROUBLESHOOTING.md) for more solutions
- Deploy to AWS with the [AWS Deployment Guide](docs/AWS_DEPLOYMENT.md)

## Tips for Success

- 💡 **First time?** The initial build takes 3-5 minutes (Docker images)
- 💡 **Subsequent starts?** Takes only 30-60 seconds
- 💡 **Database persisted?** Yes, data survives `make down` (use `make clean` to reset)
- 💡 **Hot reload works?** Yes, for both frontend and API
- 💡 **Need help?** Check `make help` or the troubleshooting guide

---

**🎉 You're all set! Start coding and enjoy the zero-configuration experience.**

