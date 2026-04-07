import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * User-specific exceptions for the Users module
 */

export class UserAlreadyExistsException extends HttpException {
  constructor(message = 'User already exists') {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message,
        code: 'USER_ALREADY_EXISTS',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.CONFLICT,
    );
  }
}

export class InvalidReferralException extends HttpException {
  constructor(message = 'Invalid referral number or not eligible') {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message,
        code: 'INVALID_REFERRAL',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}

export class UserNotFoundException extends HttpException {
  constructor(message = 'User not found') {
    super(
      {
        statusCode: HttpStatus.NOT_FOUND,
        message,
        code: 'USER_NOT_FOUND',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.NOT_FOUND,
    );
  }
}
