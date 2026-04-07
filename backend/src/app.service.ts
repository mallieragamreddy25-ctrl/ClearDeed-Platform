import { Injectable } from '@nestjs/common';

/**
 * App Service
 * 
 * Main application service with health checks
 * Used by AppController
 */
@Injectable()
export class AppService {
  /**
   * Get health status
   * 
   * @returns Health status object
   */
  getHealthStatus(): {
    status: string;
    timestamp: string;
    version: string;
    database: string;
  } {
    return {
      status: 'UP',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      database: 'connected',
    };
  }

  /**
   * Get API info
   * 
   * @returns API information
   */
  getApiInfo(): {
    name: string;
    description: string;
    version: string;
    documentation: string;
  } {
    return {
      name: 'ClearDeed API',
      description: 'End-to-end verified real estate & investment execution platform',
      version: '1.0.0',
      documentation: 'https://api.cleardeed.com/docs',
    };
  }
}
