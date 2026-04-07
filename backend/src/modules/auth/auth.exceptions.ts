/**
 * Custom Authentication Exceptions
 */

import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Thrown when OTP is invalid or expired
 */
export class InvalidOtpException extends HttpException {
  constructor(message: string = 'Invalid or expired OTP') {
    super(message, HttpStatus.UNAUTHORIZED);
  }
}

/**
 * Thrown when rate limit is exceeded
 */
export class RateLimitExceededException extends HttpException {
  constructor(message: string = 'Too many attempts. Please try again later.') {
    super(message, HttpStatus.TOO_MANY_REQUESTS);
  }
}

/**
 * Thrown when user is not found
 */
export class UserNotFoundException extends HttpException {
  constructor(message: string = 'User not found') {
    super(message, HttpStatus.NOT_FOUND);
  }
}
