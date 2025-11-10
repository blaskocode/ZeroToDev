# Backend API

Express + TypeScript backend service with PostgreSQL and Redis integration.

## Features

- ✅ Express.js web framework
- ✅ TypeScript for type safety
- ✅ PostgreSQL database with connection pooling
- ✅ Redis cache integration
- ✅ Comprehensive health check endpoints
- ✅ Automatic database migrations
- ✅ Hot reload in development
- ✅ Multi-stage Docker build
- ✅ Graceful shutdown handling
- ✅ CORS enabled
- ✅ Error handling middleware

## API Endpoints

### Health Checks

- `GET /health` - Basic health check
- `GET /health/db` - Database health check
- `GET /health/cache` - Redis health check
- `GET /health/all` - Comprehensive health check (all services)

### Root

- `GET /` - API information and available endpoints

## Development

### Prerequisites

- Node.js 20+
- npm 10+
- PostgreSQL 16 (or via Docker)
- Redis 7 (or via Docker)

### Local Setup

```bash
# Install dependencies
npm install

# Start development server with hot reload
npm run dev

# Build for production
npm run build

# Run production build
npm start
```

### Environment Variables

See `.env.example` in project root. Key variables:

- `PORT` - Server port (default: 4000)
- `NODE_ENV` - Environment (development/production)
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string

## Docker

### Development

```bash
# Build
docker build --target development -t zero-to-dev-api:dev .

# Run
docker run -p 4000:4000 zero-to-dev-api:dev
```

### Production

```bash
# Build
docker build --target production -t zero-to-dev-api:prod .

# Run
docker run -p 4000:4000 zero-to-dev-api:prod
```

## Project Structure

```
src/
├── index.ts              # Entry point & server setup
├── config/
│   └── env.ts            # Environment configuration
├── routes/
│   └── health.routes.ts  # Health check endpoints
├── db/
│   └── postgres.ts       # PostgreSQL client & migrations
├── cache/
│   └── redis.ts          # Redis client & helpers
└── middleware/
    └── errorHandler.ts   # Error handling middleware
```

## Database

### Migrations

Migrations run automatically on startup. The migration system:
- Creates a `migrations` table to track applied migrations
- Runs pending migrations in order
- Skips already-applied migrations

Current migrations:
- `001_create_health_checks_table` - Creates health_checks table for logging

### Manual Migration

```bash
npm run migrate
```

## Testing

```bash
# Run tests (not yet implemented)
npm test

# Lint code (not yet implemented)
npm run lint
```

## Production Considerations

- ✅ Multi-stage Docker build for small image size
- ✅ Non-root user in production container
- ✅ Connection pooling for PostgreSQL
- ✅ Automatic reconnection for Redis
- ✅ Graceful shutdown handling
- ✅ Request logging
- ✅ Error handling and logging
- ⚠️ Add authentication middleware (future)
- ⚠️ Add rate limiting (future)
- ⚠️ Add request validation (future)
- ⚠️ Add comprehensive tests (future)

