import { Router, Request, Response } from 'express';
import { checkDatabaseHealth, logHealthCheck } from '../db/postgres';
import { checkRedisHealth } from '../cache/redis';

const router = Router();

/**
 * Basic health check
 * GET /health
 */
router.get('/', async (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    service: 'zero-to-dev-api',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

/**
 * Database health check
 * GET /health/db
 */
router.get('/db', async (req: Request, res: Response) => {
  try {
    const isHealthy = await checkDatabaseHealth();
    
    if (isHealthy) {
      await logHealthCheck('database', 'healthy');
      res.json({
        status: 'ok',
        service: 'postgresql',
        timestamp: new Date().toISOString(),
        message: 'Database connection is healthy'
      });
    } else {
      res.status(503).json({
        status: 'error',
        service: 'postgresql',
        timestamp: new Date().toISOString(),
        message: 'Database connection is unhealthy'
      });
    }
  } catch (error) {
    console.error('Database health check error:', error);
    res.status(503).json({
      status: 'error',
      service: 'postgresql',
      timestamp: new Date().toISOString(),
      message: (error as Error).message
    });
  }
});

/**
 * Redis/Cache health check
 * GET /health/cache
 */
router.get('/cache', async (req: Request, res: Response) => {
  try {
    const isHealthy = await checkRedisHealth();
    
    if (isHealthy) {
      await logHealthCheck('redis', 'healthy');
      res.json({
        status: 'ok',
        service: 'redis',
        timestamp: new Date().toISOString(),
        message: 'Redis connection is healthy'
      });
    } else {
      res.status(503).json({
        status: 'error',
        service: 'redis',
        timestamp: new Date().toISOString(),
        message: 'Redis connection is unhealthy'
      });
    }
  } catch (error) {
    console.error('Redis health check error:', error);
    res.status(503).json({
      status: 'error',
      service: 'redis',
      timestamp: new Date().toISOString(),
      message: (error as Error).message
    });
  }
});

/**
 * Comprehensive health check (all services)
 * GET /health/all
 */
router.get('/all', async (req: Request, res: Response) => {
  try {
    const [dbHealthy, cacheHealthy] = await Promise.all([
      checkDatabaseHealth(),
      checkRedisHealth()
    ]);

    const allHealthy = dbHealthy && cacheHealthy;
    const statusCode = allHealthy ? 200 : 503;

    const response = {
      status: allHealthy ? 'ok' : 'degraded',
      timestamp: new Date().toISOString(),
      services: {
        api: {
          status: 'ok',
          uptime: process.uptime()
        },
        database: {
          status: dbHealthy ? 'ok' : 'error',
          healthy: dbHealthy
        },
        cache: {
          status: cacheHealthy ? 'ok' : 'error',
          healthy: cacheHealthy
        }
      },
      system: {
        memory: {
          used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
          unit: 'MB'
        },
        uptime: Math.round(process.uptime()),
        nodeVersion: process.version,
        platform: process.platform
      }
    };

    // Log aggregate health status
    await logHealthCheck('all_services', allHealthy ? 'healthy' : 'degraded');

    res.status(statusCode).json(response);
  } catch (error) {
    console.error('Comprehensive health check error:', error);
    res.status(503).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      message: (error as Error).message
    });
  }
});

export default router;

