import { Type } from 'class-transformer';
import { IsOptional, IsNumber, IsString, IsEnum, IsISO8601, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * ActivityLogFilterDto - Query Filters for Activity Logs
 *
 * Data Transfer Object for filtering activity logs with pagination.
 * All fields are optional for flexible querying.
 *
 * Supports:
 * - Filtering by action type
 * - Filtering by admin user ID
 * - Filtering by related entity type
 * - Date range filtering
 * - Pagination (page and limit)
 */
export class ActivityLogFilterDto {
  /**
   * Filter by action type
   *
   * @example "user_created"
   */
  @ApiPropertyOptional({
    description: 'Filter by action type',
    example: 'user_created',
  })
  @IsOptional()
  @IsString({ message: 'Action type must be a string' })
  action_type?: string;

  /**
   * Filter by admin user ID
   *
   * @example 1
   */
  @ApiPropertyOptional({
    description: 'Filter by admin user ID',
    example: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Admin ID must be a number' })
  admin_id?: number;

  /**
   * Filter by related entity type
   *
   * Examples: 'property', 'deal', 'commission', 'user'
   *
   * @example "property"
   */
  @ApiPropertyOptional({
    description: 'Filter by related entity type (property, deal, commission, user, etc.)',
    example: 'property',
  })
  @IsOptional()
  @IsString({ message: 'Entity type must be a string' })
  related_entity_type?: string;

  /**
   * Start date for date range filter (ISO 8601 format)
   *
   * @example "2024-01-01T00:00:00Z"
   */
  @ApiPropertyOptional({
    description: 'Start date for date range (ISO 8601 format)',
    example: '2024-01-01T00:00:00Z',
  })
  @IsOptional()
  @IsISO8601({}, { message: 'Start date must be in ISO 8601 format' })
  start_date?: string;

  /**
   * End date for date range filter (ISO 8601 format)
   *
   * @example "2024-01-31T23:59:59Z"
   */
  @ApiPropertyOptional({
    description: 'End date for date range (ISO 8601 format)',
    example: '2024-01-31T23:59:59Z',
  })
  @IsOptional()
  @IsISO8601({}, { message: 'End date must be in ISO 8601 format' })
  end_date?: string;

  /**
   * Page number for pagination (1-indexed)
   *
   * @example 1
   */
  @ApiPropertyOptional({
    description: 'Page number (1-indexed)',
    example: 1,
    minimum: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Page must be a number' })
  @Min(1, { message: 'Page must be at least 1' })
  page?: number;

  /**
   * Number of records per page
   *
   * Min: 1, Max: 100
   *
   * @example 20
   */
  @ApiPropertyOptional({
    description: 'Number of records per page',
    example: 20,
    minimum: 1,
    maximum: 100,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Limit must be a number' })
  @Min(1, { message: 'Limit must be at least 1' })
  limit?: number;

  /**
   * Period for summary endpoint
   *
   * @example "daily"
   */
  @ApiPropertyOptional({
    description: 'Period for summary (daily or weekly)',
    enum: ['daily', 'weekly'],
    example: 'daily',
  })
  @IsOptional()
  @IsEnum(['daily', 'weekly'], {
    message: 'Period must be either daily or weekly',
  })
  period?: 'daily' | 'weekly';
}
