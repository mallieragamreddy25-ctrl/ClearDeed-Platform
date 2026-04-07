import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReferralPartnersService } from './referral-partners.service';
import { ReferralPartnersController } from './referral-partners.controller';
import { ReferralPartner } from '../../database/entities/referral-partner.entity';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { User } from '../../database/entities/user.entity';

/**
 * Referral Partners Module
 * 
 * Complete module for managing referral partners (agents and verified users)
 * 
 * Features:
 * - Self-service registration for agents and verified users
 * - Admin approval and verification workflow
 * - Commission tracking and earnings management
 * - Status management (pending, approved, suspended, rejected)
 * - Mobile verification against User database
 * - Commission ledger and earnings summary
 * 
 * Entities Used:
 * - ReferralPartner: Core partner data and profile
 * - CommissionLedger: Commission tracking per partner and deal
 * - User: User reference and verification
 * 
 * Endpoints (with /v1/referral-partners prefix):
 * Public:
 * - POST / - Register new agent/verified user
 * - GET /verify-mobile - Verify mobile number against User database
 * 
 * Protected (JWT Required):
 * - GET / - List partners with pagination and filters
 * - GET /:id - Get partner details with commission history
 * - PUT /:id - Update partner info (self-service or admin)
 * - GET /:id/commission-summary - Get earnings and commission ledger
 * 
 * Admin Only:
 * - POST /:id/approve - Approve pending/under-review partner
 * - POST /:id/reject - Reject pending/under-review partner
 * - POST /:id/suspend - Suspend active partner
 * - POST /:id/reactivate - Reactivate suspended partner
 * 
 * Dependencies:
 * - TypeORM for database access
 * - JWT authentication guard
 * - Is-Admin decorator for admin-only endpoints
 * 
 * Exports:
 * - ReferralPartnersService: For use by other modules (Deals, Commissions, etc.)
 * 
 * Usage by other modules:
 * ```typescript
 * @Module({
 *   imports: [ReferralPartnersModule],
 *   // Then inject ReferralPartnersService
 * })
 * export class DealsModule {}
 * ```
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([ReferralPartner, CommissionLedger, User]),
  ],
  controllers: [ReferralPartnersController],
  providers: [ReferralPartnersService],
  exports: [ReferralPartnersService],
})
export class ReferralPartnersModule {}
