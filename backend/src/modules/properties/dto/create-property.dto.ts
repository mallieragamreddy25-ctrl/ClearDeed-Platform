import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  Min,
  MinLength,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/**
 * CreatePropertyDto
 * 
 * DTO for creating new property listings
 * Only sellers (profile_type='seller') can create properties
 * Property starts in 'submitted' status for admin verification
 * 
 * Status Flow:
 * submitted → under_verification → verified → live → sold → rejected
 * 
 * Validation:
 * - All required fields must be provided
 * - Prices and areas must be positive
 * - Category must be valid enum value
 * - Title and location are required for buyer discovery
 */
export class CreatePropertyDto {
  @ApiProperty({
    enum: ['land', 'individual_house', 'commercial', 'agriculture'],
    description: 'Category of the property',
    example: 'individual_house',
  })
  @IsEnum(['land', 'individual_house', 'commercial', 'agriculture'], {
    message: 'Category must be one of: land, individual_house, commercial, agriculture',
  })
  category: 'land' | 'individual_house' | 'commercial' | 'agriculture';

  @ApiProperty({
    description: 'Property title/headline',
    minLength: 5,
    maxLength: 255,
    example: 'Beautiful 2BHK House in Bangalore',
  })
  @IsString()
  @MinLength(5, { message: 'Title must be at least 5 characters' })
  @MaxLength(255, { message: 'Title must not exceed 255 characters' })
  title: string;

  @ApiPropertyOptional({
    description: 'Detailed description of the property',
    example: 'Well-maintained house with garden and parking. 2 bedrooms, 1 kitchen, 1 living area.',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    description: 'Exact location/address of the property',
    minLength: 3,
    maxLength: 255,
    example: '123 Main Street, Koramangala, Bangalore',
  })
  @IsString()
  @MinLength(3, { message: 'Location must be at least 3 characters' })
  @MaxLength(255, { message: 'Location must not exceed 255 characters' })
  location: string;

  @ApiProperty({
    description: 'City where the property is located',
    minLength: 2,
    maxLength: 100,
    example: 'Bangalore',
  })
  @IsString()
  @MinLength(2, { message: 'City must be at least 2 characters' })
  @MaxLength(100, { message: 'City must not exceed 100 characters' })
  city: string;

  @ApiPropertyOptional({
    description: 'Postal code (max 10 characters)',
    maxLength: 10,
    example: '560034',
  })
  @IsOptional()
  @IsString()
  @MaxLength(10, { message: 'Postal code must not exceed 10 characters' })
  pincode?: string;

  @ApiProperty({
    description: 'Price of the property in INR',
    type: Number,
    minimum: 0,
    example: 5000000,
  })
  @Type(() => Number)
  @IsNumber()
  @Min(0, { message: 'Price must be greater than or equal to 0' })
  price: number;

  @ApiProperty({
    description: 'Area of the property (value depends on area_unit)',
    type: Number,
    minimum: 0,
    example: 1500,
  })
  @Type(() => Number)
  @IsNumber()
  @Min(0, { message: 'Area must be greater than or equal to 0' })
  area: number;

  @ApiPropertyOptional({
    enum: ['sqft', 'sqm'],
    description: 'Unit of area measurement (Square Feet or Square Meters)',
    example: 'sqft',
  })
  @IsOptional()
  @IsEnum(['sqft', 'sqm'], { message: 'Area unit must be sqft or sqm' })
  area_unit?: 'sqft' | 'sqm';

  @ApiProperty({
    enum: ['freehold', 'leasehold'],
    description: 'Ownership type',
    example: 'freehold',
  })
  @IsEnum(['freehold', 'leasehold'], {
    message: 'Ownership type must be freehold or leasehold',
  })
  ownership_type: 'freehold' | 'leasehold';

  @ApiPropertyOptional({
    description: 'Additional property specifications as JSON string',
    example:
      '{"bedrooms": 2, "bathrooms": 1, "parking": true, "furnished": "semi-furnished"}',
  })
  @IsOptional()
  @IsString()
  specification_json?: string;
}

