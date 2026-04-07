import {
  IsOptional,
  IsString,
  IsNumber,
  IsEnum,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * PropertyFilterDto
 * 
 * Request query parameters for filtering property listings
 * Used in the GET /properties endpoint for buyers to discover properties
 * 
 * Supports:
 * - Filtering by category (land, house, commercial, agriculture)
 * - Filtering by city/location
 * - Price range filtering (min and max price)
 * - Property status filtering
 * - Text search by title/description
 * - Pagination (page, limit)
 */
export class PropertyFilterDto {
  @ApiPropertyOptional({
    enum: ['land', 'individual_house', 'commercial', 'agriculture'],
    description: 'Filter by property category',
    example: 'individual_house',
  })
  @IsOptional()
  @IsEnum(['land', 'individual_house', 'commercial', 'agriculture'], {
    message: 'Category must be one of: land, individual_house, commercial, agriculture',
  })
  category?: string;

  @ApiPropertyOptional({
    description: 'Filter by city',
    example: 'Bangalore',
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    type: Number,
    description: 'Minimum price filter in INR',
    minimum: 0,
    example: 1000000,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0, { message: 'min_price must be at least 0' })
  min_price?: number;

  @ApiPropertyOptional({
    type: Number,
    description: 'Maximum price filter in INR',
    minimum: 0,
    example: 10000000,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0, { message: 'max_price must be at least 0' })
  max_price?: number;

  @ApiPropertyOptional({
    enum: ['verified', 'live', 'submitted', 'under_verification', 'sold', 'rejected'],
    description: 'Filter by property status',
    example: 'live',
  })
  @IsOptional()
  @IsEnum(['verified', 'live', 'submitted', 'under_verification', 'sold', 'rejected'], {
    message: 'Status must be one of: verified, live, submitted, under_verification, sold, rejected',
  })
  status?: string;

  @ApiPropertyOptional({
    type: Number,
    description: 'Page number for pagination (default: 1)',
    minimum: 1,
    example: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1, { message: 'page must be at least 1' })
  page?: number = 1;

  @ApiPropertyOptional({
    type: Number,
    description: 'Records per page (default: 20, max: 100)',
    minimum: 1,
    maximum: 100,
    example: 20,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1, { message: 'limit must be at least 1' })
  @Max(100, { message: 'limit must not exceed 100' })
  limit?: number = 20;

  @ApiPropertyOptional({
    description: 'Search by property title or description',
    example: 'beautiful house near metro',
  })
  @IsOptional()
  @IsString()
  search?: string;
}
