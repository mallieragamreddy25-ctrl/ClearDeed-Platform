import {
  IsString,
  IsOptional,
  IsDateString,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * Close Deal DTO
 * 
 * Request body for closing a deal
 * Admin-only operation
 * Triggers:
 * - Property status change to 'sold'
 * - Commission ledger creation
 * - Deal status change to 'closed'
 */
export class CloseDealDto {
  @ApiPropertyOptional({
    description: 'Additional notes for deal closure',
    type: String,
    example: 'Deal completed with verification',
  })
  @IsString()
  @IsOptional()
  notes?: string;

  @ApiPropertyOptional({
    description: 'Closure date in ISO format',
    type: String,
    example: '2026-03-31T10:00:00Z',
  })
  @IsDateString()
  @IsOptional()
  closure_date?: string;

  @ApiPropertyOptional({
    description: 'URL to verification proof document',
    type: String,
    example: 'https://example.com/verification-proof.pdf',
  })
  @IsString()
  @IsOptional()
  verification_proof_url?: string;
}

