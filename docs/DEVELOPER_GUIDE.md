# Developer Guide

Complete guide to developing with the Zero-to-Running Developer Environment.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Available Commands](#available-commands)
- [Service Details](#service-details)
- [Troubleshooting](#troubleshooting)
- [Hot Reload](#hot-reload)
- [Database Access](#database-access)
- [Redis Access](#redis-access)
- [Viewing Logs](#viewing-logs)
- [Environment Variables](#environment-variables)
- [Port Configuration](#port-configuration)
- [Best Practices](#best-practices)

---

## Getting Started

### Prerequisites

Before starting, ensure you have:
- Docker (>= 24.0)
- Docker Compose (>= 2.0)
- Node.js (>= 20.0) - for CLI tools
- Make
- Git (>= 2.0)

Run the prerequisites validation:

```bash
./scripts/validate-prereqs.sh
```

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd zero-to-dev
   ```

2. **Set up environment:**
   ```bash
   cp .env.example .env
   ```
   
   Review and update `.env` if needed (defaults work for local development).

3. **Start the environment:**
   ```bash
   make dev
   ```

The first startup will take 2-4 minutes as Docker builds images. Subsequent starts are much faster (30-60 seconds).

---

## Development Workflow

### Starting Development

```bash
make dev
```

This command:
1. ✓ Validates prerequisites (Docker, Docker Compose, etc.)
2. ✓ Checks port availability
3. ✓ Creates `.env` from `.env.example` if missing
4. ✓ Builds Docker images
5. ✓ Starts all services (PostgreSQL, Redis, API, Frontend)
6. ✓ Waits for health checks to pass
7. ✓ Displays service URLs and useful commands

Expected output:
```
   ____                _         ____             
  |_  /___ _ __ ___   | |_ ___  |  _ \  _____   __
   / // _ \ '__/ _ \  | __/ _ \ | | | |/ _ \ \ / /
  / /|  __/ | | (_) | | || (_) || |_| |  __/\ V / 
 /____\___|_|  \___/   \__\___/ |____/ \___| \_/  

✓ Development Environment Ready!

Access Your Services:
  ✓ Frontend (React + Vite): http://localhost:5173
  ✓ API (Express): http://localhost:4000
  ✓ API Health Check: http://localhost:4000/health
```

### Making Changes

All code changes are automatically reflected due to hot reload:

- **Frontend (React):** Changes appear immediately in the browser
- **API (Express):** Server restarts automatically when you save files
- **Database:** Schema changes require migrations (see [Database Access](#database-access))

### Checking Status

```bash
make status
```

Shows:
- Container status (running/stopped)
- Health check results
- Port usage
- Resource consumption
- Service URLs
- Useful commands

### Viewing Logs

```bash
# All services
make logs

# Specific service
docker compose logs -f api
docker compose logs -f frontend
docker compose logs -f db
docker compose logs -f redis
```

### Stopping Development

```bash
make down
```

This gracefully stops all services while preserving data volumes.

### Clean Restart

If you need a fresh start (removes all data):

```bash
make clean
```

⚠️ This removes all containers, volumes, and cached data. You'll be prompted to confirm.

---

## Available Commands

### Local Development

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make prereqs` | Validate prerequisites |
| `make dev` | Start development environment |
| `make down` | Stop all services |
| `make status` | Show service status dashboard |
| `make logs` | View logs from all services |
| `make clean` | Remove all containers and volumes |

### AWS Deployment

| Command | Description |
|---------|-------------|
| `make aws-bootstrap` | Bootstrap Terraform backend (one-time) |
| `make aws-plan` | Show planned infrastructure changes |
| `make aws-deploy` | Deploy to AWS |
| `make aws-outputs` | Show deployment URLs |
| `make aws-destroy` | Destroy all AWS resources |

### Docker Compose Commands

For more control, use Docker Compose directly:

```bash
# Restart a specific service
docker compose restart api

# Rebuild a specific service
docker compose up -d --build frontend

# View service configuration
docker compose config

# Execute command in container
docker compose exec api npm run migrate

# Scale a service
docker compose up -d --scale api=3
```

---

## Service Details

### Frontend (React + Vite)

- **URL:** http://localhost:5173
- **Technology:** React 18, TypeScript, Vite, Tailwind CSS
- **Hot Reload:** ✓ Enabled
- **Build Time:** ~2-3 seconds for changes

**Files watched:**
- `frontend/src/**/*`

**Configuration:**
- `frontend/vite.config.ts` - Vite configuration
- `frontend/tailwind.config.js` - Tailwind configuration
- `frontend/tsconfig.json` - TypeScript configuration

**Development tips:**
```bash
# Install new package
cd frontend
npm install <package-name>

# Run linter
npm run lint

# Build for production
npm run build
```

### API (Express + TypeScript)

- **URL:** http://localhost:4000
- **Health Check:** http://localhost:4000/health
- **Technology:** Express.js, TypeScript, Node.js 20
- **Hot Reload:** ✓ Enabled (nodemon)

**Endpoints:**
- `GET /health` - Basic health check
- `GET /health/db` - Database connectivity check
- `GET /health/cache` - Redis connectivity check
- `GET /health/all` - Comprehensive health check

**Files watched:**
- `api/src/**/*.ts`

**Configuration:**
- `api/tsconfig.json` - TypeScript configuration
- `api/package.json` - Dependencies and scripts

**Development tips:**
```bash
# Install new package
cd api
npm install <package-name>

# Run database migration
docker compose exec api npm run migrate

# Access API shell
docker compose exec api /bin/sh
```

### PostgreSQL Database

- **URL:** localhost:5432
- **Database:** appdb
- **User:** dev
- **Password:** devpass
- **Version:** PostgreSQL 16 (Alpine)

**Persistent Storage:** Data stored in Docker volume `zerotoDev_postgres_data`

### Redis Cache

- **URL:** localhost:6379
- **Version:** Redis 7 (Alpine)
- **Persistence:** RDB snapshots enabled

**Persistent Storage:** Data stored in memory (ephemeral by default)

---

## Troubleshooting

### Port Conflicts

**Problem:** Port already in use

```
Error: Bind for 0.0.0.0:4000 failed: port is already allocated
```

**Solution:**

1. Check what's using the port:
   ```bash
   lsof -i :4000
   ```

2. Stop the conflicting process or previous instance:
   ```bash
   make down
   ```

3. If needed, change the port in `.env`:
   ```bash
   PORT=4001  # Change API port
   ```

### Docker Not Running

**Problem:** Docker daemon not accessible

```
Cannot connect to the Docker daemon
```

**Solution:**

1. Start Docker Desktop
2. Wait for it to fully initialize (green icon)
3. Verify: `docker info`

### Services Not Healthy

**Problem:** Services fail health checks

**Solution:**

1. Check logs for errors:
   ```bash
   make logs
   ```

2. Check specific service:
   ```bash
   docker compose logs api
   ```

3. Restart unhealthy service:
   ```bash
   docker compose restart api
   ```

4. If persistent, clean restart:
   ```bash
   make clean
   make dev
   ```

### Database Connection Errors

**Problem:** API can't connect to database

**Solution:**

1. Verify database is running:
   ```bash
   docker compose ps db
   ```

2. Check database logs:
   ```bash
   docker compose logs db
   ```

3. Verify connection string in `.env`:
   ```bash
   DATABASE_URL=postgresql://dev:devpass@db:5432/appdb
   ```

4. Restart database:
   ```bash
   docker compose restart db
   ```

### Frontend Not Loading

**Problem:** Frontend shows blank page or errors

**Solution:**

1. Check frontend logs:
   ```bash
   docker compose logs frontend
   ```

2. Verify API is accessible:
   ```bash
   curl http://localhost:4000/health
   ```

3. Check browser console for errors (F12)

4. Verify `VITE_API_URL` in `.env`:
   ```bash
   VITE_API_URL=http://localhost:4000
   ```

### Slow Startup

**Problem:** `make dev` takes too long

**Expected:** First run: 2-4 minutes, Subsequent runs: 30-60 seconds

**If slower:**

1. Check Docker resource allocation (Docker Desktop → Settings → Resources)
2. Recommended: 4GB RAM, 2 CPUs minimum
3. Clean Docker cache: `docker system prune -a`
4. Check disk space: `df -h`

### Permission Errors

**Problem:** Permission denied errors

**Solution:**

1. Ensure scripts are executable:
   ```bash
   chmod +x scripts/*.sh
   ```

2. If on Linux, add user to docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

---

## Hot Reload

### How It Works

**Frontend:**
- Vite watches `frontend/src/` directory
- Changes trigger instant HMR (Hot Module Replacement)
- Browser updates without full reload
- State is preserved when possible

**API:**
- Nodemon watches `api/src/` directory
- Changes trigger automatic server restart
- Takes ~2-3 seconds to reload
- In-flight requests may fail during restart

### What Triggers Reload

**Frontend:**
- ✓ TypeScript files (`.ts`, `.tsx`)
- ✓ CSS files
- ✓ Component files
- ✗ Configuration files (`vite.config.ts`, `package.json`)

**API:**
- ✓ TypeScript files (`.ts`)
- ✓ Route files
- ✓ Middleware files
- ✗ Configuration files (`package.json`)

### Configuration Changes

For changes to configuration files, restart the specific service:

```bash
docker compose restart frontend
docker compose restart api
```

---

## Database Access

### Using psql CLI

```bash
# Connect to database
docker compose exec db psql -U dev -d appdb

# Run SQL query
docker compose exec db psql -U dev -d appdb -c "SELECT * FROM health_checks;"

# Dump database
docker compose exec db pg_dump -U dev appdb > backup.sql

# Restore database
docker compose exec -T db psql -U dev -d appdb < backup.sql
```

### Common psql Commands

```sql
-- List all tables
\dt

-- Describe table structure
\d health_checks

-- List all databases
\l

-- List all schemas
\dn

-- Quit
\q
```

### Running Migrations

Migrations are automatically run on API startup. To manually run migrations:

```bash
docker compose exec api npm run migrate
```

### Creating Migrations

1. Create migration file in `api/src/db/migrations/`:
   ```sql
   -- 002_add_users_table.sql
   CREATE TABLE users (
     id SERIAL PRIMARY KEY,
     email VARCHAR(255) UNIQUE NOT NULL,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```

2. Restart API to apply:
   ```bash
   docker compose restart api
   ```

### Database GUI Tools

You can connect using GUI tools:

- **DBeaver:** Free, cross-platform
- **pgAdmin:** Free, web-based
- **TablePlus:** Commercial, native apps

**Connection details:**
- Host: `localhost`
- Port: `5432`
- Database: `appdb`
- Username: `dev`
- Password: `devpass`

---

## Redis Access

### Using redis-cli

```bash
# Connect to Redis
docker compose exec redis redis-cli

# Set a key
docker compose exec redis redis-cli SET mykey "Hello"

# Get a key
docker compose exec redis redis-cli GET mykey

# List all keys
docker compose exec redis redis-cli KEYS '*'

# Get Redis info
docker compose exec redis redis-cli INFO
```

### Common Redis Commands

```bash
# Ping Redis
PING

# Check memory usage
INFO memory

# Monitor all commands (debugging)
MONITOR

# Flush all data (⚠️ destructive)
FLUSHALL
```

### Redis GUI Tools

- **RedisInsight:** Free, official Redis GUI
- **Medis:** Free, macOS native

**Connection details:**
- Host: `localhost`
- Port: `6379`
- No password (local development)

---

## Viewing Logs

### All Services

```bash
make logs
```

### Specific Service

```bash
docker compose logs -f api       # API logs
docker compose logs -f frontend  # Frontend logs
docker compose logs -f db        # PostgreSQL logs
docker compose logs -f redis     # Redis logs
```

### Log Options

```bash
# Follow logs (real-time)
docker compose logs -f

# Show last 100 lines
docker compose logs --tail=100

# Show logs since timestamp
docker compose logs --since 2024-01-01T00:00:00

# Show logs with timestamps
docker compose logs -t
```

### Log Levels

**API Logs:**
- `INFO` - Normal operations
- `WARN` - Warnings (non-critical)
- `ERROR` - Errors (requires attention)
- `DEBUG` - Detailed debugging information

**Frontend Logs:**
- Vite server output
- Build status
- HMR updates
- Compilation errors

---

## Environment Variables

### Local Development (.env)

```bash
# Database
POSTGRES_USER=dev
POSTGRES_PASSWORD=devpass
POSTGRES_DB=appdb
DATABASE_URL=postgresql://dev:devpass@db:5432/appdb

# Redis
REDIS_URL=redis://redis:6379

# API
PORT=4000
NODE_ENV=development

# Frontend
VITE_API_URL=http://localhost:4000
```

### Changing Variables

1. Update `.env` file
2. Restart affected services:
   ```bash
   docker compose restart api frontend
   ```

### Production Variables

For AWS deployment, variables are set in:
- GitHub Secrets (CI/CD)
- Terraform variables (`infra/terraform/terraform.tfvars`)
- ECS task definitions

---

## Port Configuration

### Default Ports

| Service | Port | Protocol |
|---------|------|----------|
| Frontend | 5173 | HTTP |
| API | 4000 | HTTP |
| PostgreSQL | 5432 | PostgreSQL |
| Redis | 6379 | Redis |

### Changing Ports

To avoid conflicts, modify `docker-compose.yml`:

```yaml
services:
  api:
    ports:
      - "4001:4000"  # Host:Container
```

Or use `.env`:

```bash
API_PORT=4001
```

Then update `docker-compose.yml`:

```yaml
services:
  api:
    ports:
      - "${API_PORT:-4000}:4000"
```

---

## Best Practices

### Development

1. **Always run `make dev`** instead of `docker compose up`
   - Includes health checks and validation
   - Better error messages
   - Timing information

2. **Check status before debugging**
   ```bash
   make status
   ```

3. **View logs for errors**
   ```bash
   make logs
   ```

4. **Commit working .env.example**
   - Never commit `.env` (in `.gitignore`)
   - Keep `.env.example` updated with all required variables

### Database

1. **Use migrations for schema changes**
   - Don't modify database directly
   - Create migration files
   - Version control all migrations

2. **Back up before major changes**
   ```bash
   docker compose exec db pg_dump -U dev appdb > backup-$(date +%Y%m%d).sql
   ```

3. **Test migrations locally first**
   - Apply migration
   - Verify functionality
   - Then commit

### Docker

1. **Clean up regularly**
   ```bash
   docker system prune -f
   ```

2. **Monitor resource usage**
   ```bash
   docker stats
   ```

3. **Use specific tags for images**
   - Not: `FROM node:latest`
   - Better: `FROM node:20-alpine`

### Code Quality

1. **Run linters before committing**
   ```bash
   cd api && npm run lint
   cd frontend && npm run lint
   ```

2. **Keep files under 750 lines**
   - Split large files into modules
   - Better organization and testing

3. **Write meaningful commit messages**
   ```bash
   git commit -m "feat(api): add user authentication endpoint"
   ```

### Troubleshooting

1. **Read error messages carefully**
   - Often contain the solution
   - Check stack traces

2. **Isolate the problem**
   - Test each service independently
   - Check logs for each service

3. **When stuck, clean restart**
   ```bash
   make clean
   make dev
   ```

---

## Getting Help

### Documentation

- [Architecture](./ARCHITECTURE.md) - System design and patterns
- [GitHub Setup](./GITHUB_SETUP.md) - CI/CD configuration
- [Infrastructure](../infra/README.md) - AWS deployment
- [Main README](../README.md) - Project overview

### Common Issues

See [Troubleshooting](#troubleshooting) section above.

### Still Stuck?

1. Check service logs: `make logs`
2. Check service status: `make status`
3. Try clean restart: `make clean && make dev`
4. Review error messages carefully
5. Search GitHub issues
6. Open a new issue with:
   - Steps to reproduce
   - Error messages
   - Output of `make status`
   - Relevant logs

---

## Quick Reference

### Common Tasks

```bash
# Start development
make dev

# Check status
make status

# View logs
make logs

# Stop services
make down

# Clean restart
make clean && make dev

# Database access
docker compose exec db psql -U dev -d appdb

# Redis access
docker compose exec redis redis-cli

# API shell
docker compose exec api /bin/sh

# Frontend shell
docker compose exec frontend /bin/sh
```

### Useful URLs

- Frontend: http://localhost:5173
- API: http://localhost:4000
- API Health: http://localhost:4000/health
- API DB Health: http://localhost:4000/health/db
- API Cache Health: http://localhost:4000/health/cache

---

## Summary

You now have everything you need to develop effectively with this environment:

- ✓ Enhanced CLI with progress indicators and helpful messages
- ✓ Hot reload for instant feedback
- ✓ Health checks to ensure everything works
- ✓ Database and cache access
- ✓ Comprehensive logging
- ✓ Troubleshooting guides
- ✓ Best practices

**Start developing:**

```bash
make dev
```

Happy coding! 🚀

