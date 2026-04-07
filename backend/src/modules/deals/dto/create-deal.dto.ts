import {
  IsNumber,
  IsOptional,
  Min,
  IsNotEmpty,
  IsDecimal,
  ValidateIf,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * Create Deal DTO
 * 
 * Request body for creating a new deal
 * Admin-only operation
 * Either property_id or project_id must be provided (XOR validation)
 * 
 * Commission Calculation:
 * - Buyer Commission: 2% of transaction_value
 * - Seller Commission: 2% of transaction_value
 * - Referral Commission: 1% of transaction_value (50% of buyer/seller commission)
 * - Platform Commission: 1% of transaction_value (50% of buyer/seller commission)
 */
export class CreateDealDto {
  @ApiProperty({
    description: 'Buyer user ID',
    type: Number,
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty({ message: 'Buyer user ID is required' })
  buyer_user_id: number;

  @ApiProperty({
    description: 'Seller user ID',
    type: Number,
    example: 2,
  })
  @IsNumber()
  @IsNotEmpty({ message: 'Seller user ID is required' })
  seller_user_id: number;

  @ApiPropertyOptional({
    description: 'Property ID (either property_id or project_id required)',
    type: Number,
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  property_id?: number;

  @ApiPropertyOptional({
    description: 'Project ID (either property_id or project_id required)',
    type: Number,
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  project_id?: number;

  @ApiProperty({
    description: 'Transaction value in rupees (decimal: 15 digits, 2 decimals)',
    type: String,
    example: '1000000.00',
  })
  @IsNotEmpty({ message: 'Transaction value is required' })
  @Min(0, { message: 'Transaction value must be greater than or equal to 0' })
  transaction_value: number;

  @ApiPropertyOptional({
    description: 'Referral partner ID for this deal',
    type: Number,
    example: 5,
  })
  @IsNumber()
  @IsOptional()
  referral_partner_id?: number;

  @ApiPropertyOptional({
    description: 'Custom buyer commission percentage (locked at deal creation)',
    type: Number,
    default: 2,
    example: 2,
  })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Buyer commission percentage must be greater than or equal to 0' })
  buyer_commission_percentage?: number;

  @ApiPropertyOptional({
    description: 'Custom seller commission percentage (locked at deal creation)',
    type: Number,
    default: 2,
    example: 2,
  })
  @IsOptional()
  @IsNumber()
  @Min(0, { message: 'Seller commission percentage must be greater than or equal to 0' })
  seller_commission_percentage?: number;

  /**
   * Validation: Either property_id or project_id must be provided
   * This is a custom validation rule at controller level
   */
}

