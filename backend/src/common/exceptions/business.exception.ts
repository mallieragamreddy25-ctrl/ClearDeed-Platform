import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Custom Business Exception
 * Used for domain-specific errors that don't fit standard HTTP exceptions
 * 
 * Examples:
 * - Invalid referral code
 * - Property verification failed
 * - Insufficient funds for investment
 * - Deal not eligible for closing
 */
export class BusinessException extends HttpException {
  constructor(
    message: string,
    statusCode: HttpStatus = HttpStatus.BAD_REQUEST,
    public readonly code?: string,
  ) {
    super(
      {
        statusCode,
        message,
        code,
        timestamp: new Date().toISOString(),
      },
      statusCode,
    );
  }
}

/**
 * Specific business exceptions for common scenarios
 */
export class InvalidReferralException extends BusinessException {
  constructor(message = 'Invalid referral code or number') {
    super(message, HttpStatus.BAD_REQUEST, 'INVALID_REFERRAL');
  }
}

export class PropertyVerificationFailedException extends BusinessException {
  constructor(message = 'Property verification failed') {
    super(message, HttpStatus.BAD_REQUEST, 'VERIFICATION_FAILED');
  }
}

export class DealNotEligibleException extends BusinessException {
  constructor(message = 'Deal is not eligible for this operation') {
    super(message, HttpStatus.BAD_REQUEST, 'DEAL_NOT_ELIGIBLE');
  }
}

/**
 * Resource not found exception
 * Thrown when a requested resource does not exist
 */
export class ResourceNotFoundException extends BusinessException {
  constructor(resource: string, identifier?: string | number) {
    const message = `${resource} not found${identifier ? ` (ID: ${identifier})` : ''}`;
    super(message, HttpStatus.NOT_FOUND, 'RESOURCE_NOT_FOUND');
  }
}

export class UnauthorizedException extends BusinessException {
  constructor(message = 'Unauthorized access') {
    super(message, HttpStatus.UNAUTHORIZED, 'UNAUTHORIZED');
  }
}
