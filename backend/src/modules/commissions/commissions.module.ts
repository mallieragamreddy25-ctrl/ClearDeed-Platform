import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommissionsController } from './commissions.controller';
import { CommissionsService } from './commissions.service';
import { CommissionLedgerRepository } from './commission-ledger.repository';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { Deal } from '../../database/entities/deal.entity';
import { User } from '../../database/entities/user.entity';

/**
 * Commissions Module - Commission Tracking and Reporting
 *
 * Complete module for managing commission ledger, tracking, and reporting
 * across the ClearDeed real estate platform.
 *
 * Features:
 * - Paginated commission ledger with advanced filtering
 * - Commission summaries by type and status
 * - Per-user commission reports
 * - Deal-specific commission tracking
 * - CSV export functionality
 * - Admin reporting and analytics
 * - Commission statistics and distribution
 *
 * Entities:
 * - CommissionLedger: Main commission tracking table
 * - Deal: Associated deals for commission context
 * - User: User information for commissions
 *
 * Endpoints (with /v1/commissions prefix):
 * - GET /ledger - Paginated list with filters (pagination: 20 items default, max 100)
 * - GET /summary - Overall commission summary
 * - GET /user/:userId - Per-user commission summary
 * - GET /deal/:dealId - Deal-specific commissions
 * - GET /export - CSV export with filters
 * - GET /statistics - Analytics (admin only)
 * - GET /pending - Pending commissions (admin only)
 *
 * Filters & Query Parameters:
 * - commission_type: buyer_fee, seller_fee, platform_fee, referral_fee
 * - status: pending, approved, paid
 * - deal_id: Filter by specific deal
 * - user_id: Filter by user (admin only)
 * - date range: from_date and to_date (ISO 8601 format)
 * - page: Page number for pagination (default: 1)
 * - limit: Items per page (default: 20, max: 100)
 *
 * Business Logic:
 * 1. Commission Types:
 *    - buyer_fee: Fee charged from buyer side of transaction
 *    - seller_fee: Fee charged from seller side of transaction
 *    - platform_fee: ClearDeed platform fee for facilitating deal
 *    - referral_fee: Commission for referral partners/agents
 *
 * 2. Commission States:
 *    - pending: Newly created commission, awaiting approval
 *    - approved: Commission approved for payment
 *    - paid: Commission has been paid
 *
 * 3. Permission Model:
 *    - Non-admin users: Can view only their own commissions
 *    - Admins: Can view and export all commissions
 *    - Deal visibility: Only view deals user is involved with (parties)
 *
 * 4. Reporting:
 *    - Summary: Aggregated amounts by type and status
 *    - User summary: Per-user commission breakdown
 *    - Deal summary: All commissions for a specific deal
 *    - Statistics: Distribution and analytics for admins
 *
 * 5. Export:
 *    - CSV format with proper escaping
 *    - Supports all filters from ledger endpoint
 *    - Includes all commission fields
 *
 * Dependencies:
 * - TypeORM for database access
 * - JWT authentication guard for security
 * - Is-Admin decorator for admin-only endpoints
 *
 * Integration Points:
 * - Used by Deal module for commission calculations
 * - Used by User module for agent/seller commission tracking
 * - Used by Payment module for commission payouts
 *
 * Usage by Other Modules:
 * ```typescript
 * @Module({
 *   imports: [CommissionsModule],
 * })
 * export class PaymentModule {
 *   constructor(private commissionsService: CommissionsService) {}
 *
 *   // Access commission data through service
 *   async processPayments() {
 *     const pending = await this.commissionsService.getPendingCommissions();
 *   }
 * }
 * ```
 *
 * Example API Usage:
 *
 * 1. Get all pending commissions for current user:
 *    ```
 *    GET /v1/commissions/ledger?status=pending
 *    Headers: Authorization: Bearer <token>
 *    ```
 *
 * 2. Get commission summary for a user:
 *    ```
 *    GET /v1/commissions/user/123
 *    Headers: Authorization: Bearer <token>
 *    ```
 *
 * 3. Export paid commissions as CSV:
 *    ```
 *    GET /v1/commissions/export?status=paid
 *    Headers: Authorization: Bearer <token>
 *    Response: CSV file download
 *    ```
 *
 * 4. Get deal commissions (admin):
 *    ```
 *    GET /v1/commissions/deal/456
 *    Headers: Authorization: Bearer <admin-token>
 *    ```
 *
 * Production Considerations:
 * - All monetary values stored as decimal(12,2) in database
 * - Commission calculations locked at deal creation time
 * - Audit trail for all status changes needed
 * - Commission reconciliation reports needed
 * - Integration with accounting/payment systems needed
 * - Tax calculation needed for reports
 * - Referral partner verification needed
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([CommissionLedger, Deal, User]),
  ],
  controllers: [CommissionsController],
  providers: [CommissionsService, CommissionLedgerRepository],
  exports: [CommissionsService],
})
export class CommissionsModule {}
