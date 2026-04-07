import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

/**
 * Global HTTP Exception Filter
 * Catches all HTTP exceptions and formats them consistently
 * Logs errors for debugging and monitoring
 * Returns standardized error responses
 * 
 * Handles:
 * - Validation errors (400)
 * - Authentication errors (401)
 * - Authorization errors (403)
 * - Not found errors (404)
 * - Server errors (500+)
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger('HttpExceptionFilter');

  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    const errorResponse = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      message:
        typeof exceptionResponse === 'object'
          ? (exceptionResponse as any).message || 'Unknown error'
          : exceptionResponse,
      ...(typeof exceptionResponse === 'object' && {
        errors: (exceptionResponse as any).message,
      }),
    };

    // Log errors
    if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url}`,
        exception.stack,
      );
    } else if (status >= 400) {
      this.logger.warn(
        `${request.method} ${request.url} - ${status}`,
      );
    }

    response.status(status).json(errorResponse);
  }
}
