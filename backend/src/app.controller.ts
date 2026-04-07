import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

/**
 * App Controller
 * 
 * Root endpoints:
 * - GET /: API info
 * - GET /health: Health check
 */
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  /**
   * Get API information
   * 
   * @returns API info
   */
  @Get()
  getApiInfo() {
    return this.appService.getApiInfo();
  }

  /**
   * Health check endpoint
   * 
   * @returns Health status
   */
  @Get('health')
  getHealthStatus() {
    return this.appService.getHealthStatus();
  }
}
