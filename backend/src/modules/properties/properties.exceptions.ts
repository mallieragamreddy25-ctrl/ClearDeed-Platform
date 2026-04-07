import { HttpStatus } from '@nestjs/common';
import { BusinessException } from '../../common/exceptions/business.exception';

/**
 * Properties Module - Custom Exceptions
 * 
 * Specialized exceptions for property management operations
 * All exceptions extend BusinessException with proper HTTP status codes
 */

/**
 * PropertyNotFoundException
 * Thrown when property ID does not exist
 * 
 * Usage:
 * throw new PropertyNotFoundException(propertyId);
 */
export class PropertyNotFoundException extends BusinessException {
  constructor(propertyId: number) {
    super(
      `Property with ID ${propertyId} not found`,
      HttpStatus.NOT_FOUND,
      'PROPERTY_NOT_FOUND',
    );
  }
}

/**
 * UnauthorizedPropertyModificationException
 * Thrown when user attempts to modify property they don't own
 * 
 * Business Rule:
 * - Only property owner (seller) can modify own properties
 * - Only admins can verify/reject properties
 * 
 * Usage:
 * throw new UnauthorizedPropertyModificationException();
 */
export class UnauthorizedPropertyModificationException extends BusinessException {
  constructor() {
    super(
      'You are not authorized to modify this property. Only the property owner can edit.',
      HttpStatus.FORBIDDEN,
      'UNAUTHORIZED_MODIFICATION',
    );
  }
}

/**
 * PropertyStatusLockedException
 * Thrown when attempting to modify property in locked status
 * 
 * Business Rules:
 * - Properties can only be edited if status is 'submitted' or 'under_verification'
 * - Once 'verified', 'live', or 'sold', property becomes read-only
 * - Rejected properties cannot be edited
 * 
 * Usage:
 * throw new PropertyStatusLockedException('verified');
 */
export class PropertyStatusLockedException extends BusinessException {
  constructor(currentStatus: string) {
    super(
      `Property cannot be modified in '${currentStatus}' status. Only properties in 'submitted' or 'under_verification' status can be edited.`,
      HttpStatus.BAD_REQUEST,
      'PROPERTY_LOCKED',
    );
  }
}

/**
 * InvalidDocumentTypeException
 * Thrown when invalid document type is provided
 * 
 * Valid types: 'title_deed', 'survey', 'tax_proof', 'approval_letter'
 * 
 * Usage:
 * throw new InvalidDocumentTypeException(invalidType);
 */
export class InvalidDocumentTypeException extends BusinessException {
  constructor(invalidType: string) {
    super(
      `Invalid document type: '${invalidType}'. Must be one of: title_deed, survey, tax_proof, approval_letter`,
      HttpStatus.BAD_REQUEST,
      'INVALID_DOCUMENT_TYPE',
    );
  }
}

/**
 * DuplicateExpressInterestException
 * Thrown when buyer attempts to express interest twice in same property
 * 
 * Business Rule:
 * - Unique constraint on (property_id, buyer_id)
 * - One buyer can express interest only once per property
 * 
 * Usage:
 * throw new DuplicateExpressInterestException();
 */
export class DuplicateExpressInterestException extends BusinessException {
  constructor() {
    super(
      'You have already expressed interest in this property',
      HttpStatus.CONFLICT,
      'DUPLICATE_INTEREST',
    );
  }
}

/**
 * PropertyVerificationFailedException
 * Thrown when property verification operation fails
 * 
 * Usage:
 * throw new PropertyVerificationFailedException('Missing required documents');
 */
export class PropertyVerificationFailedException extends BusinessException {
  constructor(reason?: string) {
    super(
      `Property verification failed${reason ? `: ${reason}` : ''}`,
      HttpStatus.BAD_REQUEST,
      'VERIFICATION_FAILED',
    );
  }
}

/**
 * UserNotSellerException
 * Thrown when non-seller attempts to create property
 * 
 * Business Rule:
 * - Only users with profile_type='seller' can create properties
 * - Investors, agents, and buyers must switch to seller mode
 * 
 * Usage:
 * throw new UserNotSellerException();
 */
export class UserNotSellerException extends BusinessException {
  constructor() {
    super(
      'Only sellers can create properties. Please switch to seller mode in your profile.',
      HttpStatus.FORBIDDEN,
      'USER_NOT_SELLER',
    );
  }
}

/**
 * InvalidPropertyStatusTransitionException
 * Thrown when property status transition is invalid
 * 
 * Valid transitions:
 * - submitted → under_verification
 * - under_verification → verified | rejected
 * - verified → live
 * - live → sold
 * 
 * Usage:
 * throw new InvalidPropertyStatusTransitionException(from, to);
 */
export class InvalidPropertyStatusTransitionException extends BusinessException {
  constructor(from: string, to: string) {
    super(
      `Cannot transition property status from '${from}' to '${to}'`,
      HttpStatus.BAD_REQUEST,
      'INVALID_STATUS_TRANSITION',
    );
  }
}
