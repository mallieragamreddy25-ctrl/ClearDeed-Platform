import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Custom Deals Module Exceptions
 * 
 * Specific business exceptions for deal management operations
 */

/**
 * Invalid Deal Property Exception
 * Thrown when property is not verified or in invalid state
 */
export class InvalidDealPropertyException extends HttpException {
  constructor(message = 'Property is not verified or in invalid state for deal creation') {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message,
        code: 'INVALID_DEAL_PROPERTY',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}

/**
 * Deal Already Closed Exception
 * Thrown when attempting to close an already closed deal
 */
export class DealAlreadyClosedException extends HttpException {
  constructor(message = 'Deal is already closed') {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message,
        code: 'DEAL_ALREADY_CLOSED',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.CONFLICT,
    );
  }
}

/**
 * Deal Not Found Exception
 * Thrown when deal cannot be found
 */
export class DealNotFoundException extends HttpException {
  constructor(dealId: number | string) {
    super(
      {
        statusCode: HttpStatus.NOT_FOUND,
        message: `Deal with ID ${dealId} not found`,
        code: 'DEAL_NOT_FOUND',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.NOT_FOUND,
    );
  }
}

/**
 * Invalid Buyer Exception
 * Thrown when buyer validation fails
 */
export class InvalidBuyerException extends HttpException {
  constructor(message = 'Buyer is invalid or does not have complete profile') {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message,
        code: 'INVALID_BUYER',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}

/**
 * Invalid Seller Exception
 * Thrown when seller validation fails
 */
export class InvalidSellerException extends HttpException {
  constructor(message = 'Seller is invalid or property cannot be sold by this user') {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message,
        code: 'INVALID_SELLER',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}

/**
 * Property Not Verified Exception
 * Thrown when property is not verified
 */
export class PropertyNotVerifiedException extends HttpException {
  constructor(propertyId: number) {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message: `Property with ID ${propertyId} is not verified`,
        code: 'PROPERTY_NOT_VERIFIED',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}

/**
 * Property Already Sold Exception
 * Thrown when property is already sold
 */
export class PropertyAlreadySoldException extends HttpException {
  constructor(propertyId: number) {
    super(
      {
        statusCode: HttpStatus.CONFLICT,
        message: `Property with ID ${propertyId} is already sold`,
        code: 'PROPERTY_ALREADY_SOLD',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.CONFLICT,
    );
  }
}

/**
 * Same Buyer Seller Exception
 * Thrown when buyer and seller are the same user
 */
export class SameBuyerSellerException extends HttpException {
  constructor() {
    super(
      {
        statusCode: HttpStatus.BAD_REQUEST,
        message: 'Buyer and seller must be different users',
        code: 'SAME_BUYER_SELLER',
        timestamp: new Date().toISOString(),
      },
      HttpStatus.BAD_REQUEST,
    );
  }
}
