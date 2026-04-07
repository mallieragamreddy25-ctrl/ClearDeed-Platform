import { IsEnum, IsOptional, IsNumber, IsString, Min, Max, IsDateString } from 'class-validator';
import { CommissionType, CommissionStatus } from './commissions.interface';

/**
 * Commission Ledger List Query DTO
 *
 * Provides filtering and pagination options for retrieving commission ledger entries.
 * All parameters are optional with sensible defaults.
 *
 * Usage:
 * ```
 * GET /commissions/ledger?commission_type=buyer_fee&status=pending&page=1&limit=20
 * ```
 */
export class CommissionLedgerQueryDto {
  /**
   * Commission type filter
   * Optional - if not provided, returns all types
   *
   * @example "buyer_fee"
   */
  @IsOptional()
  @IsEnum(CommissionType, {
    message: 'commission_type must be one of: buyer_fee, seller_fee, platform_fee, referral_fee',
  })
  commission_type?: string;

  /**
   * Commission status filter
   * Optional - if not provided, returns all statuses
   *
   * @example "pending"
   */
  @IsOptional()
  @IsEnum(CommissionStatus, {
    message: 'status must be one of: pending, approved, paid',
  })
  status?: string;

  /**
   * Deal ID filter
   * Optional - filter commissions for a specific deal
   *
   * @example 123
   */
  @IsOptional()
  @IsNumber()
  @Min(1)
  deal_id?: number;

  /**
   * User ID filter
   * Optional - filter commissions for a specific user
   *
   * @example 456
   */
  @IsOptional()
  @IsNumber()
  @Min(1)
  user_id?: number;

  /**
   * Start date filter (ISO 8601 format)
   * Optional - filter commissions from this date onwards
   *
   * @example "2024-01-01T00:00:00Z"
   */
  @IsOptional()
  @IsDateString()
  from_date?: string;

  /**
   * End date filter (ISO 8601 format)
   * Optional - filter commissions up to this date
   *
   * @example "2024-12-31T23:59:59Z"
   */
  @IsOptional()
  @IsDateString()
  to_date?: string;

  /**
   * Page number for pagination (1-indexed)
   * Default: 1
   * Minimum: 1
   *
   * @example 1
   */
  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number = 1;

  /**
   * Number of items per page
   * Default: 20
   * Minimum: 1
   * Maximum: 100
   *
   * @example 20
   */
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

/**
 * Commission Summary Query DTO
 *
 * Provides filtering options for commission summary statistics.
 *
 * Usage:
 * ```
 * GET /commissions/summary?from_date=2024-01-01&to_date=2024-12-31
 * ```
 */
export class CommissionSummaryQueryDto {
  /**
   * Start date filter (ISO 8601 format)
   * Optional - filter commissions from this date onwards
   *
   * @example "2024-01-01T00:00:00Z"
   */
  @IsOptional()
  @IsDateString()
  from_date?: string;

  /**
   * End date filter (ISO 8601 format)
   * Optional - filter commissions up to this date
   *
   * @example "2024-12-31T23:59:59Z"
   */
  @IsOptional()
  @IsDateString()
  to_date?: string;

  /**
   * Commission type filter
   * Optional - if not provided, returns summary for all types
   *
   * @example "buyer_fee"
   */
  @IsOptional()
  @IsEnum(CommissionType, {
    message: 'commission_type must be one of: buyer_fee, seller_fee, platform_fee, referral_fee',
  })
  commission_type?: string;

  /**
   * Status filter
   * Optional - if not provided, returns summary for all statuses
   *
   * @example "paid"
   */
  @IsOptional()
  @IsEnum(CommissionStatus, {
    message: 'status must be one of: pending, approved, paid',
  })
  status?: string;
}

/**
 * User Commission Query DTO
 *
 * Parameters for retrieving per-user commission summaries.
 *
 * Usage:
 * ```
 * GET /commissions/user/123
 * ```
 */
export class UserCommissionQueryDto {
  /**
   * Start date filter (ISO 8601 format)
   * Optional - filter commissions from this date onwards
   *
   * @example "2024-01-01T00:00:00Z"
   */
  @IsOptional()
  @IsDateString()
  from_date?: string;

  /**
   * End date filter (ISO 8601 format)
   * Optional - filter commissions up to this date
   *
   * @example "2024-12-31T23:59:59Z"
   */
  @IsOptional()
  @IsDateString()
  to_date?: string;

  /**
   * Include individual commission entries
   * Default: false
   *
   * @example false
   */
  @IsOptional()
  include_details?: boolean = false;
}

/**
 * Deal Commission Query DTO
 *
 * Parameters for retrieving deal-specific commission details.
 *
 * Usage:
 * ```
 * GET /commissions/deal/123
 * ```
 */
export class DealCommissionQueryDto {
  /**
   * Include all commission ledger entries for the deal
   * Default: false
   *
   * @example false
   */
  @IsOptional()
  include_ledger?: boolean = false;
}

/**
 * Commission Export Query DTO
 *
 * Parameters for exporting commission data to CSV.
 *
 * Usage:
 * ```
 * GET /commissions/export?commission_type=buyer_fee&status=paid&from_date=2024-01-01
 * ```
 */
export class CommissionExportQueryDto {
  /**
   * Commission type filter
   * Optional - if not provided, exports all types
   *
   * @example "buyer_fee"
   */
  @IsOptional()
  @IsEnum(CommissionType, {
    message: 'commission_type must be one of: buyer_fee, seller_fee, platform_fee, referral_fee',
  })
  commission_type?: string;

  /**
   * Commission status filter
   * Optional - if not provided, exports all statuses
   *
   * @example "paid"
   */
  @IsOptional()
  @IsEnum(CommissionStatus, {
    message: 'status must be one of: pending, approved, paid',
  })
  status?: string;

  /**
   * Start date filter (ISO 8601 format)
   * Optional - filter commissions from this date onwards
   *
   * @example "2024-01-01T00:00:00Z"
   */
  @IsOptional()
  @IsDateString()
  from_date?: string;

  /**
   * End date filter (ISO 8601 format)
   * Optional - filter commissions up to this date
   *
   * @example "2024-12-31T23:59:59Z"
   */
  @IsOptional()
  @IsDateString()
  to_date?: string;

  /**
   * Export format
   * Only CSV supported currently
   * Default: "csv"
   *
   * @example "csv"
   */
  @IsOptional()
  @IsString()
  format?: string = 'csv';
}
