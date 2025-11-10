import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import healthRoutes from './routes/health.routes';
import { errorHandler } from './middleware/errorHandler';
import { connectDatabase, disconnectDatabase } from './db/postgres';
import { connectRedis, disconnectRedis } from './cache/redis';

// Load environment variables
dotenv.config();

const app: Express = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware (simple version)
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.path} - ${res.statusCode} - ${duration}ms`);
  });
  next();
});

// Routes
app.use('/health', healthRoutes);

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.json({
    service: 'zero-to-dev-api',
    version: '1.0.0',
    status: 'running',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      healthDb: '/health/db',
      healthCache: '/health/cache',
      healthAll: '/health/all'
    }
  });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Cannot ${req.method} ${req.path}`,
    timestamp: new Date().toISOString()
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Initialize and start server
const startServer = async () => {
  try {
    console.log('🚀 Starting Zero-to-Dev API...\n');
    
    // Connect to database
    await connectDatabase();
    
    // Connect to Redis
    await connectRedis();
    
    console.log(''); // Empty line for readability
    
    // Start HTTP server
    const server = app.listen(PORT, () => {
      console.log(`✓ Server running on port ${PORT}`);
      console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`✓ Health check: http://localhost:${PORT}/health`);
      console.log('\n✅ API is ready to handle requests!\n');
    });
    
    // Graceful shutdown handler
    const gracefulShutdown = async () => {
      console.log('\n🛑 Graceful shutdown initiated...');
      
      // Close server
      server.close(async () => {
        console.log('✓ HTTP server closed');
        
        // Disconnect from database
        await disconnectDatabase();
        
        // Disconnect from Redis
        await disconnectRedis();
        
        console.log('✓ All connections closed');
        process.exit(0);
      });
      
      // Force shutdown after 10 seconds
      setTimeout(() => {
        console.error('⚠️  Forced shutdown after timeout');
        process.exit(1);
      }, 10000);
    };
    
    // Handle shutdown signals
    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

export default app;

