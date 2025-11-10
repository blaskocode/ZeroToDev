import Redis from 'ioredis';
import config from '../config/env';

let redis: Redis | null = null;

/**
 * Initialize and connect to Redis
 */
export const connectRedis = async (): Promise<void> => {
  try {
    console.log('📦 Connecting to Redis...');
    
    redis = new Redis(config.redis.url, {
      maxRetriesPerRequest: config.redis.maxRetries,
      retryStrategy: (times: number) => {
        if (times > config.redis.maxRetries) {
          console.error('❌ Redis max retries exceeded');
          return null;
        }
        const delay = Math.min(times * config.redis.retryDelay, 3000);
        return delay;
      },
      reconnectOnError: (err) => {
        console.error('Redis connection error:', err.message);
        return true;
      }
    });

    // Handle connection events
    redis.on('connect', () => {
      console.log('✓ Redis connected');
    });

    redis.on('error', (err) => {
      console.error('Redis error:', err);
    });

    redis.on('close', () => {
      console.log('Redis connection closed');
    });

    // Test connection
    const pong = await redis.ping();
    if (pong !== 'PONG') {
      throw new Error('Redis PING failed');
    }

    // Set a test key
    await redis.set('connection_test', 'OK', 'EX', 10);
    
  } catch (error) {
    console.error('❌ Redis connection failed:', error);
    throw error;
  }
};

/**
 * Disconnect from Redis
 */
export const disconnectRedis = async (): Promise<void> => {
  if (redis) {
    await redis.quit();
    console.log('✓ Redis disconnected');
    redis = null;
  }
};

/**
 * Get Redis client
 */
export const getRedis = (): Redis => {
  if (!redis) {
    throw new Error('Redis client not initialized. Call connectRedis() first.');
  }
  return redis;
};

/**
 * Check if Redis is healthy
 */
export const checkRedisHealth = async (): Promise<boolean> => {
  try {
    const redis = getRedis();
    const pong = await redis.ping();
    return pong === 'PONG';
  } catch (error) {
    console.error('Redis health check failed:', error);
    return false;
  }
};

/**
 * Cache helper functions
 */

export const cache = {
  /**
   * Get value from cache
   */
  get: async (key: string): Promise<string | null> => {
    const redis = getRedis();
    return await redis.get(key);
  },

  /**
   * Set value in cache with optional expiration
   */
  set: async (key: string, value: string, expiresIn?: number): Promise<void> => {
    const redis = getRedis();
    if (expiresIn) {
      await redis.set(key, value, 'EX', expiresIn);
    } else {
      await redis.set(key, value);
    }
  },

  /**
   * Delete key from cache
   */
  del: async (key: string): Promise<void> => {
    const redis = getRedis();
    await redis.del(key);
  },

  /**
   * Check if key exists
   */
  exists: async (key: string): Promise<boolean> => {
    const redis = getRedis();
    const result = await redis.exists(key);
    return result === 1;
  },

  /**
   * Set expiration on key
   */
  expire: async (key: string, seconds: number): Promise<void> => {
    const redis = getRedis();
    await redis.expire(key, seconds);
  },

  /**
   * Get all keys matching pattern
   */
  keys: async (pattern: string): Promise<string[]> => {
    const redis = getRedis();
    return await redis.keys(pattern);
  }
};

