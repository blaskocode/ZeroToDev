import { Pool, PoolClient, QueryResult, QueryResultRow } from 'pg';
import config from '../config/env';

let pool: Pool | null = null;

/**
 * Initialize and connect to PostgreSQL database
 */
export const connectDatabase = async (): Promise<void> => {
  try {
    console.log('📦 Connecting to PostgreSQL...');
    
    // Parse connection string to check SSL mode
    const connectionString = config.database.url;
    const sslMode = connectionString.includes('sslmode=no-verify') 
      ? { rejectUnauthorized: false }
      : connectionString.includes('sslmode=require') || connectionString.includes('sslmode=prefer')
      ? { rejectUnauthorized: false } // For RDS, we need to disable cert verification or use proper CA bundle
      : undefined;

    pool = new Pool({
      connectionString: config.database.url,
      min: config.database.poolMin,
      max: config.database.poolMax,
      idleTimeoutMillis: config.database.idleTimeout,
      connectionTimeoutMillis: config.database.connectionTimeout,
      ...(sslMode && { ssl: sslMode }),
    });

    // Test connection
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as now, version() as version');
    client.release();

    console.log('✓ PostgreSQL connected');
    console.log(`  Database time: ${result.rows[0].now}`);
    
    // Run migrations
    await runMigrations();
  } catch (error) {
    console.error('❌ PostgreSQL connection failed:', error);
    throw error;
  }
};

/**
 * Disconnect from PostgreSQL database
 */
export const disconnectDatabase = async (): Promise<void> => {
  if (pool) {
    await pool.end();
    console.log('✓ PostgreSQL disconnected');
    pool = null;
  }
};

/**
 * Get database connection pool
 */
export const getPool = (): Pool => {
  if (!pool) {
    throw new Error('Database pool not initialized. Call connectDatabase() first.');
  }
  return pool;
};

/**
 * Execute a query
 */
export const query = async <T extends QueryResultRow = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> => {
  const pool = getPool();
  const start = Date.now();
  
  try {
    const result = await pool.query<T>(text, params);
    const duration = Date.now() - start;
    
    if (duration > 1000) {
      console.warn(`Slow query (${duration}ms): ${text.substring(0, 100)}...`);
    }
    
    return result;
  } catch (error) {
    console.error('Database query error:', {
      query: text,
      params,
      error: (error as Error).message
    });
    throw error;
  }
};

/**
 * Check if database is healthy
 */
export const checkDatabaseHealth = async (): Promise<boolean> => {
  try {
    const result = await query('SELECT 1 as health_check');
    return result.rows.length > 0;
  } catch (error) {
    console.error('Database health check failed:', error);
    return false;
  }
};

/**
 * Run database migrations
 */
const runMigrations = async (): Promise<void> => {
  try {
    console.log('🔄 Running database migrations...');
    
    // Create migrations table if it doesn't exist
    await query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Create health_checks table (initial migration)
    const migrationName = '001_create_health_checks_table';
    const migrationExists = await query(
      'SELECT id FROM migrations WHERE name = $1',
      [migrationName]
    );
    
    if (migrationExists.rows.length === 0) {
      await query(`
        CREATE TABLE IF NOT EXISTS health_checks (
          id SERIAL PRIMARY KEY,
          service_name VARCHAR(100) NOT NULL,
          status VARCHAR(50) NOT NULL,
          checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      
      await query(`
        CREATE INDEX IF NOT EXISTS idx_health_checks_checked_at 
        ON health_checks(checked_at)
      `);
      
      await query(
        'INSERT INTO migrations (name) VALUES ($1)',
        [migrationName]
      );
      
      console.log(`✓ Migration applied: ${migrationName}`);
    } else {
      console.log('✓ All migrations up to date');
    }
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  }
};

/**
 * Log health check to database
 */
export const logHealthCheck = async (
  serviceName: string,
  status: string
): Promise<void> => {
  try {
    await query(
      'INSERT INTO health_checks (service_name, status) VALUES ($1, $2)',
      [serviceName, status]
    );
  } catch (error) {
    // Don't throw - health check logging is non-critical
    console.error('Failed to log health check:', error);
  }
};

