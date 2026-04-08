import {
  IsString,
  IsEmail,
  IsOptional,
  IsEnum,
  MinLength,
  MaxLength,
  IsNotEmpty,
  Matches,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

/**
 * CreateUserDto - User Profile Creation Request
 *
 * Data Transfer Object for creating/completing user profile.
 * Called after successful OTP verification.
 *
 * All fields are validated using class-validator decorators.
 * Swagger documentation included for API docs generation.
 *
 * Required Fields:
 * - full_name: 3-255 characters, non-empty string
 * - email: Valid email format, globally unique
 * - city: Non-empty string
 * - profile_type: Enum - buyer, seller, or investor
 *
 * Optional Fields:
 * - budget_range: String (for buyer profiles)
 * - net_worth_range: String (for investor profiles)
 * - referral_mobile_number: Valid Indian mobile number
 */
export class CreateUserDto {
  /**
   * User's full name
   *
   * Rules:
   * - Minimum 3 characters
   * - Maximum 255 characters
   * - Cannot be empty
   * - Allows letters, numbers, spaces, hyphens
   *
   * Examples:
   * - John Doe
   * - Maria Garcia-Lopez
   * - Raj Patel Jr.
   *
   * @example "John Doe"
   */
  @ApiProperty({
    description: "User full name (3-255 characters)",
    example: "John Doe",
    minLength: 3,
    maxLength: 255,
  })
  @IsNotEmpty({ message: "Full name is required" })
  @IsString({ message: "Full name must be a string" })
  @MinLength(3, { message: "Full name must be at least 3 characters long" })
  @MaxLength(255, { message: "Full name must not exceed 255 characters" })
  full_name: string;

  /**
   * User's email address
   *
   * Rules:
   * - Must be valid email format
   * - Globally unique (checked during profile creation)
   * - Used for notifications and account recovery
   * - Case-insensitive for uniqueness check
   *
   * Examples:
   * - john.doe@example.com
   * - user+tag@domain.co.uk
   * - name.surname123@company.com
   *
   * @example "john.doe@example.com"
   */
  @ApiProperty({
    description: "User email address (must be unique)",
    example: "john.doe@example.com",
  })
  @IsNotEmpty({ message: "Email is required" })
  @IsEmail({}, { message: "Email must be a valid email address" })
  email: string;

  /**
   * User's city/location
   *
   * Rules:
   * - Non-empty string
   * - Used for property discovery and location-based features
   * - Can be any city/location string
   *
   * Examples:
   * - Mumbai
   * - Bangalore
   * - London
   *
   * @example "Mumbai"
   */
  @ApiProperty({
    description: "User city/location",
    example: "Mumbai",
  })
  @IsNotEmpty({ message: "City is required" })
  @IsString({ message: "City must be a string" })
  city: string;

  /**
   * User's profile type/role
   *
   * Determines user category and available features:
   * - buyer: User looking to purchase properties
   * - seller: User selling properties
   * - investor: User looking for investment opportunities
   *
   * Can be changed later via /profile/mode-select endpoint
   * but only one role is active at a time.
   *
   * @example "buyer"
   */
  @ApiProperty({
    description: "User profile type/role",
    enum: ["buyer", "seller", "investor"],
    example: "buyer",
  })
  @IsNotEmpty({ message: "Profile type is required" })
  @IsEnum(["buyer", "seller", "investor"], {
    message: "Profile type must be one of: buyer, seller, investor",
  })
  profile_type: "buyer" | "seller" | "investor";

  /**
   * Budget range (for buyer profiles)
   *
   * Optional field indicating buyer's budget for property purchase.
   * Format is flexible - can be any string representation.
   *
   * Examples:
   * - "50-100 Lakhs"
   * - "1-2 Crores"
   * - "₹50,00,000 - ₹1,00,00,000"
   * - "Under 30 Lakhs"
   *
   * Typically used for buyer personas.
   * Can be left empty for seller/investor profiles.
   *
   * @example "50-100 Lakhs"
   */
  @ApiPropertyOptional({
    description: "Budget range for buyer profile",
    example: "50-100 Lakhs",
  })
  @IsOptional()
  @IsString({ message: "Budget range must be a string" })
  budget_range?: string;

  /**
   * Net worth range (for investor profiles)
   *
   * Optional field indicating investor's net worth.
   * Helps qualify investment opportunities.
   *
   * Examples:
   * - "1-5 Crores"
   * - "10 Crores+"
   * - "₹1 Crore"
   * - "Above 5 Crores"
   *
   * Can be left empty for buyer/seller profiles.
   *
   * @example "1-5 Crores"
   */
  @ApiPropertyOptional({
    description: "Net worth range for investor profile",
    example: "1-5 Crores",
  })
  @IsOptional()
  @IsString({ message: "Net worth range must be a string" })
  net_worth_range?: string;

  /**
   * Referral mobile number (Indian format)
   *
   * Mobile number of person who referred this user.
   * Triggers referral rewards when validated successfully.
   *
   * Validation Rules:
   * - Must be valid Indian mobile number
   * - Referral partner must exist in system
   * - Referral partner must be approved and active
   * - Cannot refer yourself
   * - If all criteria met, referral_validated = true
   *
   * Format Examples:
   * - 9876543210 (10 digits)
   * - +919876543210 (with country code)
   * - 09876543210 (with leading 0)
   *
   * Invalid Examples:
   * - 5876543210 (starts with 5, not valid)
   * - 9876543 (too short)
   * - abc9876543210 (contains letters)
   *
   * @example "9876543210"
   */
  @ApiPropertyOptional({
    description: "Referral mobile number (Indian format)",
    example: "9876543210",
  })
  @IsOptional()
  @IsString({ message: "Referral mobile number must be a string" })
  referral_mobile_number?: string;
}
