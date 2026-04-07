/**
 * Database Configuration
 * Centralized configuration for TypeORM data source
 */

import { DataSourceOptions } from 'typeorm';

/**
 * Database configuration based on environment
 */
export const getDatabaseConfig = (): DataSourceOptions => {
  const env = process.env.NODE_ENV || 'development';
  const isProduction = env === 'production';

  return {
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    username: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'cleardeed',
    
    // Entities
    entities: [
      __dirname + '/../database/entities/**/*.{ts,js}',
    ],
    
    // Migrations
    migrations: [
      __dirname + '/../database/migrations/**/*.{ts,js}',
    ],
    
    // Synchronization (dev only)
    synchronize: !isProduction,
    
    // Logging
    logging: process.env.DB_LOGGING === 'true' || !isProduction,
    logger: 'advanced-console',
    
    // Connection pool
    poolSize: parseInt(process.env.DB_POOL_SIZE || '20'),
    
    // SSL (production)
    ssl: isProduction ? {
      rejectUnauthorized: JSON.parse(
        process.env.DB_SSL_REJECT_UNAUTHORIZED || 'true'
      ),
    } : false,
    
    // Timeout settings
    connectTimeoutMS: 10000,
    acquireTimeoutMS: 30000,
    
    // Defaults
    dropSchema: false,
    migrationsRun: isProduction,
    cli: {
      migrationsDir: 'src/database/migrations',
      entitiesDir: 'src/database/entities',
    },
  };
};

/**
 * Database connection limits and configuration
 */
export const databaseLimits = {
  maxConnections: parseInt(process.env.DB_MAX_CONNECTIONS || '50'),
  minConnections: parseInt(process.env.DB_MIN_CONNECTIONS || '5'),
  connectionTimeout: 30000,
  idleTimeout: 30000,
  maxRetries: 3,
  retryDelay: 1000,
};

/**
 * Database tuning settings
 */
export const databaseTuning = {
  queryTimeout: 30000,
  slowQueryThreshold: 2000,
  enableQueryCaching: !process.env.NODE_ENV?.includes('test'),
  cacheExpires: 3600000, // 1 hour
};
