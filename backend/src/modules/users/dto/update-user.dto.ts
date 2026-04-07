import {
  IsString,
  IsEmail,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * UpdateUserDto - User Profile Update Request
 *
 * Data Transfer Object for updating user profile.
 * Supports partial updates - all fields are optional.
 * Only provided fields are updated; others remain unchanged.
 *
 * Updatable Fields:
 * - full_name: User's name
 * - email: Email address (with uniqueness validation)
 * - city: User's location
 * - budget_range: Budget preference for buyers
 * - net_worth_range: Net worth range for investors
 *
 * Non-Updatable Fields (use other endpoints):
 * - mobile_number: Use custom admin endpoint if needed
 * - profile_type: Use /profile/mode-select endpoint
 * - is_verified, is_active: Internal flags
 * - Referral fields: Set during initial profile creation
 *
 * Validation:
 * - Email: Must be valid format and unique
 * - full_name: 3-255 characters if provided
 * - All string fields trimmed and validated
 * - Field constraints inherited from entity model
 */
export class UpdateUserDto {
  /**
   * Updated full name
   *
   * Optional. If provided:
   * - Must be 3-255 characters
   * - Can include letters, numbers, spaces, hyphens
   * - Updates user.full_name in database
   *
   * If not provided, current value is preserved.
   *
   * @example "Jane Doe"
   */
  @ApiPropertyOptional({
    description: 'Updated full name (3-255 characters)',
    example: 'Jane Doe',
    minLength: 3,
    maxLength: 255,
  })
  @IsOptional()
  @IsString({ message: 'Full name must be a string' })
  @MinLength(3, { message: 'Full name must be at least 3 characters long' })
  @MaxLength(255, { message: 'Full name must not exceed 255 characters' })
  full_name?: string;

  /**
   * Updated email address
   *
   * Optional. If provided:
   * - Must be valid email format
   * - Must be globally unique
   * - Case-insensitive uniqueness check
   * - Used for notifications and recovery
   *
   * If not provided, current email is preserved.
   *
   * Validation: Unique check performed in service layer.
   * If email already in use by another user, returns 400 error.
   *
   * @example "jane.doe@example.com"
   */
  @ApiPropertyOptional({
    description: 'Updated email address (must be unique)',
    example: 'jane.doe@example.com',
  })
  @IsOptional()
  @IsEmail({}, { message: 'Email must be a valid email address' })
  email?: string;

  /**
   * Updated city/location
   *
   * Optional. If provided:
   * - Can be any string
   * - Updates user.city in database
   * - Used for location-based property discovery
   *
   * If not provided, current city is preserved.
   *
   * @example "Bangalore"
   */
  @ApiPropertyOptional({
    description: 'Updated city/location',
    example: 'Bangalore',
  })
  @IsOptional()
  @IsString({ message: 'City must be a string' })
  city?: string;

  /**
   * Updated budget range (for buyers)
   *
   * Optional. If provided:
   * - Any string format representing budget
   * - Helps with property recommendations
   * - Can use various formats
   *
   * If not provided, current budget_range is preserved.
   *
   * Examples:
   * - "75-125 Lakhs"
   * - "1.5-2.5 Crores"
   * - "₹50,00,000 - ₹1,50,00,000"
   *
   * @example "75-125 Lakhs"
   */
  @ApiPropertyOptional({
    description: 'Updated budget range for buyer profile',
    example: '75-125 Lakhs',
  })
  @IsOptional()
  @IsString({ message: 'Budget range must be a string' })
  budget_range?: string;

  /**
   * Updated net worth range (for investors)
   *
   * Optional. If provided:
   * - Any string format representing net worth
   * - Qualifies for investment opportunities
   * - Can use various formats
   *
   * If not provided, current net_worth_range is preserved.
   *
   * Examples:
   * - "2-5 Crores"
   * - "₹2 Crore - ₹5 Crore"
   * - "Above 10 Crores"
   *
   * @example "2-5 Crores"
   */
  @ApiPropertyOptional({
    description: 'Updated net worth range for investor profile',
    example: '2-5 Crores',
  })
  @IsOptional()
  @IsString({ message: 'Net worth range must be a string' })
  net_worth_range?: string;
}
