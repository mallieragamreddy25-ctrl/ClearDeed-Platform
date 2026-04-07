import {
  IsString,
  IsEmail,
  IsPhoneNumber,
  IsEnum,
  IsOptional,
  MinLength,
  MaxLength,
  Matches,
} from 'class-validator';

/**
 * Create Referral Partner DTO
 * 
 * Used for registering new referral partners (agents or verified users)
 * Supports both self-registration and admin registration
 * 
 * Validation Rules:
 * - Mobile: Indian phone format (10 digits)
 * - Email: Valid email format
 * - Full Name: 2-255 characters
 * - City: 2-100 characters
 * - Partner Type: 'agent' or 'verified_user'
 * - License Number (agents only): Optional, 2-100 characters
 * - Agency Name (agents only): Optional, 2-255 characters
 */
export class CreateReferralPartnerDto {
  /**
   * Mobile number (unique)
   * 
   * Formats accepted:
   * - 10 digit: 9876543210
   * - With country code: +919876543210
   * - With 91: 919876543210
   * 
   * @example "9876543210" or "+919876543210"
   */
  @IsString({ message: 'Mobile number must be a string' })
  @Matches(/^[6-9]\d{9}$|^\+91[6-9]\d{9}$|^91[6-9]\d{9}$/, {
    message:
      'Invalid mobile number format. Use Indian format (10 digits with optional +91)',
  })
  mobile_number: string;

  /**
   * Full Name
   * 
   * Partner's complete name for identification
   * Min 2, Max 255 characters
   * 
   * @example "Rajesh Kumar"
   */
  @IsString({ message: 'Full name must be a string' })
  @MinLength(2, { message: 'Full name must be at least 2 characters long' })
  @MaxLength(255, { message: 'Full name must not exceed 255 characters' })
  full_name: string;

  /**
   * Email Address (unique)
   * 
   * Valid email format for communication
   * 
   * @example "rajesh@example.com"
   */
  @IsString({ message: 'Email must be a string' })
  @IsEmail({}, { message: 'Invalid email format' })
  email: string;

  /**
   * City/Location
   * 
   * Where the partner is based
   * Used for regional filtering and property matching
   * 
   * @example "Mumbai"
   */
  @IsString({ message: 'City must be a string' })
  @MinLength(2, { message: 'City must be at least 2 characters long' })
  @MaxLength(100, { message: 'City must not exceed 100 characters' })
  city: string;

  /**
   * Partner Type
   * 
   * - "agent": Licensed real estate agent
   * - "verified_user": Regular user verified for referrals
   * 
   * Determines available features and commission structures
   * 
   * @example "agent"
   */
  @IsEnum(['agent', 'verified_user'], {
    message: 'Partner type must be either "agent" or "verified_user"',
  })
  partner_type: 'agent' | 'verified_user';

  /**
   * Agent License Number (optional)
   * 
   * Required for agents, optional for verified_user
   * License or registration number from RERA or relevant authority
   * 
   * @example "MH2024-ABC12345"
   */
  @IsOptional()
  @IsString({ message: 'Agent license number must be a string' })
  @MinLength(2, {
    message: 'Agent license number must be at least 2 characters long',
  })
  @MaxLength(100, {
    message: 'Agent license number must not exceed 100 characters',
  })
  agent_license_number?: string;

  /**
   * Agency Name (optional)
   * 
   * Name of the real estate agency (for agents)
   * 
   * @example "Premium Real Estate Solutions"
   */
  @IsOptional()
  @IsString({ message: 'Agency name must be a string' })
  @MinLength(2, { message: 'Agency name must be at least 2 characters long' })
  @MaxLength(255, { message: 'Agency name must not exceed 255 characters' })
  agency_name?: string;
}
