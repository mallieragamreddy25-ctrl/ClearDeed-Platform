import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DealsService } from './deals.service';
import { DealsController } from './deals.controller';
import { Deal } from '../../database/entities/deal.entity';
import { DealReferralMapping } from '../../database/entities/deal-referral-mapping.entity';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { Property } from '../../database/entities/property.entity';
import { User } from '../../database/entities/user.entity';
import { ReferralPartner } from '../../database/entities/referral-partner.entity';
import { Project } from '../../database/entities/project.entity';

/**
 * Deals Module
 * 
 * Complete deal management module with:
 * - Deal creation and lifecycle
 * - Commission calculation and ledger tracking
 * - Referral partner management
 * - Property and project transaction handling
 * 
 * Key Features:
 * ✅ Admin-only create and close operations
 * ✅ Automatic property status locking on deal closure
 * ✅ Commission percentages locked at creation time
 * ✅ Comprehensive commission ledger creation
 * ✅ Referral partner commission tracking
 * ✅ Full pagination and filtering support
 * ✅ Complete Swagger documentation
 * 
 * Commission Structure (4% total per transaction):
 * - Buyer Fee: 2%
 * - Seller Fee: 2%
 * - Split: 1% referral partner, 1% platform (if referral exists)
 *   OR: 2% platform (if no referral exists)
 * 
 * Database Entities:
 * - Deal: Main transaction record
 * - DealReferralMapping: Referral partner links
 * - CommissionLedger: Commission tracking and payments
 * - Property: Property information
 * - User: Buyer, seller, and admin information
 * - ReferralPartner: Referral partner details
 * - Project: Project information (for project-based deals)
 * 
 * Endpoints:
 * - POST /deals: Create deal (admin-only)
 * - GET /deals/:id: Get deal details
 * - POST /deals/:id/close: Close deal (admin-only)
 * - GET /deals: List deals with pagination
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Deal,
      DealReferralMapping,
      CommissionLedger,
      Property,
      User,
      ReferralPartner,
      Project,
    ]),
  ],
  controllers: [DealsController],
  providers: [DealsService],
  exports: [DealsService],
})
export class DealsModule {}
