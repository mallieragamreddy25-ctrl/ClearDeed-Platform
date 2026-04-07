import {
  IsString,
  IsNumber,
  IsOptional,
  IsUrl,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * UpdatePropertyDto
 * 
 * Request body for updating property details
 * Only seller can update own properties
 * Cannot update once verification starts
 * Edits are only allowed if property status is 'submitted' or 'under_verification'
 */
export class UpdatePropertyDto {
  @ApiPropertyOptional({
    description: 'Property title',
    example: 'Beautiful 2BHK House in Bangalore',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    description: 'Detailed description of the property',
    example: 'Well-maintained house with garden and parking',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Exact location/address of the property',
    example: '123 Main Street, Koramangala',
  })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiPropertyOptional({
    description: 'City where the property is located',
    example: 'Bangalore',
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    description: 'Postal code',
    maxLength: 10,
    example: '560034',
  })
  @IsOptional()
  @IsString()
  pincode?: string;

  @ApiPropertyOptional({
    description: 'Price of the property in INR',
    type: Number,
    minimum: 0,
    example: 5000000,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  price?: number;

  @ApiPropertyOptional({
    description: 'Area of the property',
    type: Number,
    minimum: 0,
    example: 1500,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  area?: number;

  @ApiPropertyOptional({
    description: 'Ownership status (e.g., Freehold, Leasehold)',
    example: 'Freehold',
  })
  @IsOptional()
  @IsString()
  ownership_status?: string;

  @ApiPropertyOptional({
    description: 'Primary image URL for the property',
    example: 'https://example.com/images/property-main.jpg',
  })
  @IsOptional()
  @IsUrl()
  primary_image_url?: string;
}
