import {
  IsString,
  IsEmail,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';

/**
 * Update Referral Partner DTO
 * 
 * Used for updating referral partner information
 * Supports partial updates (all fields are optional)
 * 
 * Fields that can be updated:
 * - full_name: Partner's name
 * - email: Contact email
 * - city: Location
 * - agent_license_number: License (for agents)
 * - agency_name: Agency name (for agents)
 * 
 * NOT updatable:
 * - mobile_number: Immutable identifier
 * - partner_type: Fixed at registration
 * - status: Changed via approval/rejection endpoints
 * - is_active: Changed via suspend endpoint
 * 
 * Validation Rules:
 * - All fields optional (partial updates)
 * - Email: Valid format if provided
 * - Strings: Min 2, Max 255 characters
 */
export class UpdateReferralPartnerDto {
  /**
   * Full Name (optional update)
   * 
   * Partner's complete name for identification
   * Min 2, Max 255 characters
   * 
   * @example "Rajesh Kumar Singh"
   */
  @IsOptional()
  @IsString({ message: 'Full name must be a string' })
  @MinLength(2, { message: 'Full name must be at least 2 characters long' })
  @MaxLength(255, { message: 'Full name must not exceed 255 characters' })
  full_name?: string;

  /**
   * Email Address (optional update)
   * 
   * Valid email format for communication
   * Must be unique across system if provided
   * 
   * @example "rajesh.new@example.com"
   */
  @IsOptional()
  @IsString({ message: 'Email must be a string' })
  @IsEmail({}, { message: 'Invalid email format' })
  email?: string;

  /**
   * City/Location (optional update)
   * 
   * Where the partner is based
   * Used for regional filtering and property matching
   * 
   * @example "Bangalore"
   */
  @IsOptional()
  @IsString({ message: 'City must be a string' })
  @MinLength(2, { message: 'City must be at least 2 characters long' })
  @MaxLength(100, { message: 'City must not exceed 100 characters' })
  city?: string;

  /**
   * Agent License Number (optional update)
   * 
   * License or registration number from RERA or relevant authority
   * Only applicable for agents
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
   * Agency Name (optional update)
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
