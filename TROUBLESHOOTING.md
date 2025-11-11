# Troubleshooting Guide

Common issues and solutions for Zero-to-Running Developer Environment.

## Table of Contents

- [Docker Issues](#docker-issues)
- [Port Conflicts](#port-conflicts)
- [Service Health Check Failures](#service-health-check-failures)
- [Database Issues](#database-issues)
- [Redis Issues](#redis-issues)
- [Frontend Issues](#frontend-issues)
- [API Issues](#api-issues)
- [AWS Deployment Issues](#aws-deployment-issues)
- [Performance Issues](#performance-issues)
- [General Tips](#general-tips)

---

## Docker Issues

### Docker Not Running

**Symptoms:**
```
Cannot connect to the Docker daemon
```

**Solutions:**

1. **macOS**: Start Docker Desktop
   - Open Docker Desktop application
   - Wait for it to fully start (whale icon in menu bar)

2. **Linux**: Start Docker service
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Windows**: Start Docker Desktop
   - Launch Docker Desktop from Start menu
   - Ensure WSL2 is enabled and updated

### Docker Compose Not Found

**Symptoms:**
```
docker-compose: command not found
```

**Solutions:**

1. **Docker Compose V2** (recommended):
   ```bash
   # Test if installed
   docker compose version
   
   # If not, update Docker Desktop or install plugin
   ```

2. **Legacy docker-compose**:
   ```bash
   # Install on Linux
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

### Permission Denied Errors

**Symptoms:**
```
Got permission denied while trying to connect to the Docker daemon socket
```

**Solutions:**

1. **Linux**: Add user to docker group
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   # Or logout and login again
   ```

2. **Run with sudo** (not recommended):
   ```bash
   sudo make dev
   ```

### Disk Space Issues

**Symptoms:**
```
no space left on device
```

**Solutions:**

1. Clean up Docker resources:
   ```bash
   # Remove unused images and containers
   docker system prune -a
   
   # Remove volumes (WARNING: deletes data!)
   docker volume prune
   
   # Remove everything (WARNING: nuclear option!)
   docker system prune -a --volumes
   ```

2. Check disk usage:
   ```bash
   docker system df
   ```

---

## Port Conflicts

### Port Already Allocated

**Symptoms:**
```
Bind for 0.0.0.0:5173 failed: port is already allocated
```

**Solutions:**

1. **Find what's using the port**:
   ```bash
   # macOS/Linux
   lsof -i :5173
   
   # Windows
   netstat -ano | findstr :5173
   ```

2. **Stop the conflicting process**:
   ```bash
   # Kill process by PID (from lsof output)
   kill -9 <PID>
   ```

3. **Change port in docker-compose.yml**:
   ```yaml
   frontend:
     ports:
       - "3001:5173"  # Change left side (host port)
   ```

4. **Update .env file** if you changed API or frontend ports:
   ```bash
   VITE_API_URL=http://localhost:4001
   ```

### Common Port Conflicts

| Port | Service | Common Conflicts |
|------|---------|------------------|
| 5173 | Frontend | Vite dev server, other React apps |
| 4000 | API | Other Node.js apps |
| 5432 | PostgreSQL | Local PostgreSQL installation |
| 6379 | Redis | Local Redis installation |

**Solution**: Stop local services or change ports in `docker-compose.yml`

---

## Service Health Check Failures

### All Services Failing

**Symptoms:**
```
✗ Services failed to become healthy
```

**Solutions:**

1. **Check logs**:
   ```bash
   make logs
   ```

2. **Restart with clean slate**:
   ```bash
   make clean
   make dev
   ```

3. **Check Docker resources**:
   ```bash
   docker stats
   ```
   Ensure sufficient CPU and memory allocated to Docker.

### API Health Check Failing

**Symptoms:**
```
✗ API health check failed
```

**Solutions:**

1. **View API logs**:
   ```bash
   docker logs zero-to-dev-api
   ```

2. **Common causes**:
   - Database not ready → Wait 30 seconds and retry
   - Redis not ready → Wait 30 seconds and retry
   - Port conflict → Check port 4000
   - Build error → Check for TypeScript compilation errors

3. **Manual health check**:
   ```bash
   curl http://localhost:4000/health
   ```

### Frontend Health Check Failing

**Symptoms:**
```
✗ Frontend health check failed
```

**Solutions:**

1. **View frontend logs**:
   ```bash
   docker logs zero-to-dev-frontend
   ```

2. **Common causes**:
   - API URL misconfigured → Check `VITE_API_URL` in `.env`
   - Port conflict → Check port 5173
   - Build error → Check for compilation errors in logs

3. **Manual check**:
   ```bash
   curl http://localhost:5173
   ```

---

## Database Issues

### Cannot Connect to Database

**Symptoms:**
```
connection to database failed
ECONNREFUSED ::1:5432
```

**Solutions:**

1. **Check PostgreSQL is running**:
   ```bash
   docker ps | grep postgres
   ```

2. **Check logs**:
   ```bash
   docker logs zero-to-dev-db
   ```

3. **Verify environment variables**:
   ```bash
   # In .env file
   POSTGRES_USER=dev
   POSTGRES_PASSWORD=devpass
   POSTGRES_DB=appdb
   DATABASE_URL=postgresql://dev:devpass@db:5432/appdb
   ```

4. **Connect manually to test**:
   ```bash
   docker exec -it zero-to-dev-db psql -U dev -d appdb
   ```

### Database Connection Timeout

**Symptoms:**
```
Database connection timeout
```

**Solutions:**

1. **Increase wait time** - Database takes 10-15 seconds to initialize
2. **Check health**:
   ```bash
   docker exec zero-to-dev-db pg_isready -U dev
   ```

3. **Restart database**:
   ```bash
   docker restart zero-to-dev-db
   ```

### Migration Errors

**Symptoms:**
```
Migration failed: relation already exists
```

**Solutions:**

1. **Check migration status**:
   ```bash
   docker exec -it zero-to-dev-db psql -U dev -d appdb -c "SELECT * FROM migrations;"
   ```

2. **Reset database** (WARNING: deletes all data):
   ```bash
   make clean
   make dev
   ```

### Database Data Lost After Restart

**Symptoms:**
Data disappears after `docker compose down`

**Solutions:**

- **Normal behavior with `make clean`** - This removes volumes
- **Data persists with `make down`** - This keeps volumes
- **Check volumes**:
  ```bash
  docker volume ls | grep postgres
  ```

---

## Redis Issues

### Cannot Connect to Redis

**Symptoms:**
```
Error connecting to Redis
ECONNREFUSED ::1:6379
```

**Solutions:**

1. **Check Redis is running**:
   ```bash
   docker ps | grep redis
   ```

2. **Check logs**:
   ```bash
   docker logs zero-to-dev-redis
   ```

3. **Test connection**:
   ```bash
   docker exec -it zero-to-dev-redis redis-cli ping
   # Should respond: PONG
   ```

4. **Verify environment variable**:
   ```bash
   # In .env file
   REDIS_URL=redis://redis:6379
   ```

### Redis Memory Issues

**Symptoms:**
```
OOM command not allowed when used memory > 'maxmemory'
```

**Solutions:**

1. **Clear Redis cache**:
   ```bash
   docker exec -it zero-to-dev-redis redis-cli FLUSHALL
   ```

2. **Increase memory limit** in `docker-compose.yml`:
   ```yaml
   redis:
     command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
   ```

---

## Frontend Issues

### Frontend Not Loading

**Symptoms:**
- Blank page at http://localhost:5173
- "Connection refused" error

**Solutions:**

1. **Check if frontend is running**:
   ```bash
   docker ps | grep frontend
   curl http://localhost:5173
   ```

2. **Check logs**:
   ```bash
   docker logs zero-to-dev-frontend -f
   ```

3. **Clear browser cache** and hard refresh (Cmd+Shift+R or Ctrl+Shift+R)

### Hot Reload Not Working

**Symptoms:**
Code changes don't reflect in browser

**Solutions:**

1. **Verify volume mount** in `docker-compose.yml`:
   ```yaml
   frontend:
     volumes:
       - ./frontend:/app
       - /app/node_modules
   ```

2. **Restart frontend container**:
   ```bash
   docker restart zero-to-dev-frontend
   ```

3. **Check Vite config** in `frontend/vite.config.ts`:
   ```typescript
   server: {
     watch: {
       usePolling: true  // Required for Docker
     }
   }
   ```

### API Calls Failing (CORS)

**Symptoms:**
```
Access to fetch at 'http://localhost:4000' has been blocked by CORS policy
```

**Solutions:**

1. **Check VITE_API_URL** in `.env`:
   ```bash
   VITE_API_URL=http://localhost:4000
   ```

2. **Verify CORS is enabled** in `api/src/index.ts`:
   ```typescript
   app.use(cors());
   ```

3. **Restart API**:
   ```bash
   docker restart zero-to-dev-api
   ```

### Build Errors

**Symptoms:**
```
Failed to compile
Module not found
```

**Solutions:**

1. **Install dependencies**:
   ```bash
   cd frontend
   npm install
   ```

2. **Clear node_modules and rebuild**:
   ```bash
   docker compose down
   rm -rf frontend/node_modules
   make dev
   ```

---

## API Issues

### API Not Responding

**Symptoms:**
- `curl http://localhost:4000/health` fails
- Connection timeout or refused

**Solutions:**

1. **Check API logs**:
   ```bash
   docker logs zero-to-dev-api -f
   ```

2. **Check if API is running**:
   ```bash
   docker ps | grep api
   ```

3. **Restart API**:
   ```bash
   docker restart zero-to-dev-api
   ```

### TypeScript Compilation Errors

**Symptoms:**
```
TSError: Unable to compile TypeScript
```

**Solutions:**

1. **Check for syntax errors** in `api/src/`

2. **Rebuild**:
   ```bash
   cd api
   npm run build
   ```

3. **Check tsconfig.json** is valid

### Environment Variables Not Loading

**Symptoms:**
API can't find environment variables

**Solutions:**

1. **Verify .env file exists** in project root

2. **Check docker-compose.yml** passes variables:
   ```yaml
   api:
     environment:
       NODE_ENV: development
       PORT: 4000
       DATABASE_URL: ${DATABASE_URL}
   ```

3. **Restart with new env vars**:
   ```bash
   docker compose down
   docker compose up -d
   ```

---

## AWS Deployment Issues

### Terraform Init Fails

**Symptoms:**
```
Error: Failed to get existing workspaces
```

**Solutions:**

1. **Bootstrap Terraform backend**:
   ```bash
   make aws-bootstrap
   ```

2. **Verify AWS credentials**:
   ```bash
   aws sts get-caller-identity
   ```

3. **Check AWS region** in `.env` or `infra/terraform/terraform.tfvars`

### ECR Push Failed

**Symptoms:**
```
denied: User is not authorized to perform: ecr:InitiateLayerUpload
```

**Solutions:**

1. **Login to ECR**:
   ```bash
   aws ecr get-login-password --region us-east-1 | \
     docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   ```

2. **Verify IAM permissions** - See `docs/github-actions-iam-policy.json`

3. **Create ECR repositories first**:
   ```bash
   cd infra/terraform
   terraform apply -target=module.ecr
   ```

### ECS Tasks Not Starting

**Symptoms:**
- Tasks stuck in "PENDING" state
- Tasks fail health checks

**Solutions:**

1. **Check CloudWatch logs**:
   ```bash
   aws logs tail /ecs/zero-to-dev-dev-api --follow
   ```

2. **Describe tasks**:
   ```bash
   aws ecs describe-tasks --cluster zero-to-dev-dev-cluster --tasks <task-id>
   ```

3. **Common causes**:
   - Insufficient CPU/memory
   - Image pull errors
   - Environment variables missing
   - Security group blocking traffic

### Cannot Access ALB URL

**Symptoms:**
ALB DNS returns 503 Service Unavailable

**Solutions:**

1. **Check target health**:
   ```bash
   aws elbv2 describe-target-health --target-group-arn <arn>
   ```

2. **Verify security groups** allow inbound traffic on port 80

3. **Wait 2-3 minutes** for ECS tasks to register with ALB

### API Service Failing with SSL Certificate Errors

**Symptoms:**
- API tasks crash immediately after starting
- CloudWatch logs show: `Error: self-signed certificate in certificate chain`
- API service shows 0 running tasks (desired: 1)
- ALB returns 503 for `/health` and `/health/all` endpoints

**Root Cause:**
RDS PostgreSQL uses SSL certificates that Node.js doesn't trust by default. The connection string uses `sslmode=require` which enforces SSL verification, causing the connection to fail.

**Solutions:**

1. **Verify the fix is deployed** (should already be in v1.0.0):
   - Check `infra/terraform/modules/ecs/main.tf` - DATABASE_URL should use `sslmode=no-verify`
   - Check `api/src/db/postgres.ts` - should configure SSL with `rejectUnauthorized: false`

2. **If still seeing errors, verify task definition**:
   ```bash
   aws ecs describe-task-definition --task-definition zero-to-dev-dev-api \
     --query 'taskDefinition.containerDefinitions[0].environment[?name==`DATABASE_URL`].value' \
     --output text
   ```
   Should show: `...?sslmode=no-verify`

3. **Check recent logs**:
   ```bash
   aws logs tail /ecs/zero-to-dev-dev-api --since 5m
   ```
   Look for: `✓ PostgreSQL connected` (success) or `self-signed certificate` (still failing)

4. **Force new deployment** (if fix not applied):
   ```bash
   # Update Terraform to use sslmode=no-verify
   cd infra/terraform
   terraform apply
   
   # Or trigger GitHub Actions deployment
   git commit --allow-empty -m "Force API redeployment"
   git push origin main
   ```

**Prevention:**
This issue was fixed in v1.0.0. The code now:
- Uses `sslmode=no-verify` in the connection string
- Configures the PostgreSQL Pool with `rejectUnauthorized: false` for RDS connections
- Handles SSL mode detection automatically

**Note:** For production environments, consider using proper RDS CA certificates instead of disabling verification.

### High AWS Costs

**Solutions:**

1. **Check for orphaned resources**:
   - NAT Gateway ($32/month) - Biggest cost
   - Load Balancer ($16/month)
   - Running EC2 instances

2. **Scale down**:
   ```bash
   # Reduce ECS task count
   cd infra/terraform
   # Edit terraform.tfvars: desired_count = 1
   terraform apply
   ```

3. **Destroy when not in use**:
   ```bash
   make aws-destroy
   ```

---

## Performance Issues

### Slow Build Times

**Solutions:**

1. **Use Docker layer caching**:
   - Dockerfile already optimized with multi-stage builds
   - Keep dependencies installation before code copy

2. **Increase Docker resources**:
   - Docker Desktop → Settings → Resources
   - Increase CPU and memory allocation

3. **Prune old images**:
   ```bash
   docker image prune -a
   ```

### Slow Application Response

**Solutions:**

1. **Check resource usage**:
   ```bash
   docker stats
   ```

2. **Scale up containers** (local):
   ```bash
   docker-compose up -d --scale api=2
   ```

3. **Check database queries** - Add indexes if needed

4. **Monitor logs** for slow operations:
   ```bash
   make logs | grep -i "slow"
   ```

---

## General Tips

### Start Fresh

When things go wrong, start with a clean slate:

```bash
# Nuclear option: Remove everything
make clean

# Restart
make dev
```

### Check Everything

Comprehensive health check:

```bash
# Service status
make status

# Individual health checks
curl http://localhost:4000/health
curl http://localhost:4000/health/db
curl http://localhost:4000/health/cache
curl http://localhost:4000/health/all

# Frontend
curl http://localhost:5173
```

### View Logs

```bash
# All services
make logs

# Specific service
docker logs zero-to-dev-api -f
docker logs zero-to-dev-frontend -f
docker logs zero-to-dev-db -f
docker logs zero-to-dev-redis -f

# Last 50 lines
docker logs zero-to-dev-api --tail 50
```

### Interactive Debugging

```bash
# Access running container
docker exec -it zero-to-dev-api /bin/sh

# Access database
docker exec -it zero-to-dev-db psql -U dev -d appdb

# Access Redis
docker exec -it zero-to-dev-redis redis-cli
```

### Update Dependencies

```bash
# Frontend
cd frontend
npm update
npm audit fix

# API
cd api
npm update
npm audit fix
```

---

## Still Having Issues?

If you're still experiencing problems:

1. **Search existing issues**: Check [GitHub Issues](../../issues)
2. **Check versions**: Run `./scripts/validate-prereqs.sh`
3. **Review logs**: Run `make logs` and look for errors
4. **Open an issue**: Include:
   - Operating system and version
   - Docker version
   - Node.js version
   - Complete error message
   - Steps to reproduce
   - Relevant logs

---

## FAQ

**Q: How long should the first build take?**
A: 3-5 minutes for Docker images. Subsequent starts take 30-60 seconds.

**Q: Do I need to rebuild after code changes?**
A: No! Hot reload is enabled for both frontend and API.

**Q: How do I reset the database?**
A: Run `make clean` then `make dev`

**Q: Can I use a different port?**
A: Yes, edit `docker-compose.yml` and change the host port (left side of port mapping).

**Q: Where is data stored?**
A: Docker volumes. Persists with `make down`, deleted with `make clean`.

**Q: How do I update Node dependencies?**
A: Update `package.json`, then run `docker compose build` to rebuild images.

**Q: Can I run services outside Docker?**
A: Yes, but you'll need to set up PostgreSQL and Redis locally, and update connection strings in `.env`.

**Q: Why is my Docker using so much disk space?**
A: Run `docker system prune -a` to clean up unused images and containers.

---

For more help, see:
- [Developer Guide](docs/DEVELOPER_GUIDE.md)
- [Architecture](docs/ARCHITECTURE.md)
- [AWS Deployment](docs/AWS_DEPLOYMENT.md)

