import {
  IsString,
  IsEmail,
  IsEnum,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * UpdateAdminDto - Admin User Update Request
 *
 * Data Transfer Object for updating an admin user.
 * All fields are optional for partial updates.
 *
 * Validates using class-validator decorators.
 * Swagger documentation included for API docs generation.
 */
export class UpdateAdminDto {
  /**
   * Admin's full name - Optional update
   *
   * @example "Jane Smith"
   */
  @ApiPropertyOptional({
    description: "Admin's full name",
    example: 'Jane Smith',
    minLength: 3,
    maxLength: 255,
  })
  @IsOptional()
  @IsString({ message: 'Full name must be a string' })
  @MinLength(3, { message: 'Full name must be at least 3 characters' })
  @MaxLength(255, { message: 'Full name cannot exceed 255 characters' })
  full_name?: string;

  /**
   * Admin's email address - Optional update
   *
   * @example "newemail@cleardeed.com"
   */
  @ApiPropertyOptional({
    description: 'Admin email address',
    example: 'newemail@cleardeed.com',
  })
  @IsOptional()
  @IsEmail({}, { message: 'Email must be valid' })
  email?: string;

  /**
   * Admin role - Optional update
   *
   * @example "deal_manager"
   */
  @ApiPropertyOptional({
    description: 'Admin role',
    enum: [
      'super_admin',
      'property_verifier',
      'deal_manager',
      'commission_manager',
      'support_agent',
    ],
    example: 'deal_manager',
  })
  @IsOptional()
  @IsEnum(
    ['super_admin', 'property_verifier', 'deal_manager', 'commission_manager', 'support_agent'],
    {
      message:
        'Admin role must be one of: super_admin, property_verifier, deal_manager, commission_manager, support_agent',
    },
  )
  admin_role?: 'super_admin' | 'property_verifier' | 'deal_manager' | 'commission_manager' | 'support_agent';
}
