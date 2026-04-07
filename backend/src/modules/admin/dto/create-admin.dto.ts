import {
  IsString,
  IsEmail,
  IsEnum,
  IsNotEmpty,
  MinLength,
  MaxLength,
  Matches,
  IsOptional,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * CreateAdminDto - Admin User Creation Request
 *
 * Data Transfer Object for creating a new admin user.
 * Only existing admins can create new admin accounts.
 *
 * All fields are validated using class-validator decorators.
 * Swagger documentation included for API docs generation.
 *
 * Required Fields:
 * - mobile_number: Valid Indian mobile number (10 digits)
 * - full_name: 3-255 characters
 * - email: Valid email format
 * - admin_role: One of the admin roles
 *
 * Optional Fields:
 * - None currently
 */
export class CreateAdminDto {
  /**
   * Mobile number - Unique identifier for admin
   *
   * Rules:
   * - Must be 10 digits
   * - Must match Indian mobile format
   *
   * @example "9876543210"
   */
  @ApiProperty({
    description: 'Admin mobile number (10 digits, Indian format)',
    example: '9876543210',
    minLength: 10,
    maxLength: 10,
  })
  @IsNotEmpty({ message: 'Mobile number is required' })
  @Matches(/^\d{10}$/, {
    message: 'Mobile number must be 10 digits',
  })
  mobile_number: string;

  /**
   * Admin's full name
   *
   * Rules:
   * - Minimum 3 characters
   * - Maximum 255 characters
   *
   * @example "John Doe"
   */
  @ApiProperty({
    description: "Admin's full name",
    example: 'John Doe',
    minLength: 3,
    maxLength: 255,
  })
  @IsNotEmpty({ message: 'Full name is required' })
  @IsString({ message: 'Full name must be a string' })
  @MinLength(3, { message: 'Full name must be at least 3 characters' })
  @MaxLength(255, { message: 'Full name cannot exceed 255 characters' })
  full_name: string;

  /**
   * Admin's email address - Must be globally unique
   *
   * Rules:
   * - Valid email format
   * - Must be unique across the system
   *
   * @example "admin@cleardeed.com"
   */
  @ApiProperty({
    description: 'Admin email address (must be unique)',
    example: 'admin@cleardeed.com',
  })
  @IsNotEmpty({ message: 'Email is required' })
  @IsEmail({}, { message: 'Email must be valid' })
  email: string;

  /**
   * Admin role - Determines permissions and access
   *
   * Available roles:
   * - super_admin: Full system access
   * - property_verifier: Can verify properties
   * - deal_manager: Can manage deals
   * - commission_manager: Can manage commissions
   * - support_agent: Limited support access
   *
   * @example "property_verifier"
   */
  @ApiProperty({
    description: 'Admin role (determines permissions)',
    enum: [
      'super_admin',
      'property_verifier',
      'deal_manager',
      'commission_manager',
      'support_agent',
    ],
    example: 'property_verifier',
  })
  @IsNotEmpty({ message: 'Admin role is required' })
  @IsEnum(
    ['super_admin', 'property_verifier', 'deal_manager', 'commission_manager', 'support_agent'],
    {
      message:
        'Admin role must be one of: super_admin, property_verifier, deal_manager, commission_manager, support_agent',
    },
  )
  admin_role: 'super_admin' | 'property_verifier' | 'deal_manager' | 'commission_manager' | 'support_agent';
}
