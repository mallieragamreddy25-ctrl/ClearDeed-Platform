import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import { User } from '../../database/entities/user.entity';
import { Deal } from '../../database/entities/deal.entity';
import { CommissionLedgerRepository } from './commission-ledger.repository';
import {
  ICommissionSummary,
  IUserCommissionSummary,
  IDealCommissionSummary,
  IPaginatedCommissionResponse,
  ICommissionFilter,
  ICommissionListOptions,
  ICommissionExportData,
} from './commissions.interface';

/**
 * Commissions Service
 *
 * Core business logic for commission tracking, reporting, and ledger management.
 *
 * Key Features:
 * - Fetch paginated commission ledger with filtering
 * - Generate commission summaries and reports
 * - Get per-user commission breakdowns
 * - Retrieve deal-specific commissions
 * - Export commission data to CSV
 * - Advanced commission analytics
 *
 * All methods respect user permissions:
 * - Agents can only view their own commissions
 * - Admins can view all commissions
 *
 * Commission Types:
 * - buyer_fee: Commission from buyer side
 * - seller_fee: Commission from seller side
 * - platform_fee: ClearDeed platform fee
 * - referral_fee: Referral partner commission
 */
@Injectable()
export class CommissionsService {
  private readonly logger = new Logger(CommissionsService.name);

  constructor(
    private readonly commissionRepository: CommissionLedgerRepository,
    @InjectRepository(CommissionLedger)
    private ledgerRepo: Repository<CommissionLedger>,
    @InjectRepository(Deal)
    private dealRepo: Repository<Deal>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  /**
   * Get paginated commission ledger with filters
   *
   * Retrieves commission entries with optional filtering by:
   * - Commission type (buyer_fee, seller_fee, platform_fee, referral_fee)
   * - Status (pending, approved, paid)
   * - Deal ID
   * - User ID
   * - Date range
   *
   * All users see commissions they're involved with.
   * Admins see all commissions.
   *
   * @param options - Query options with filters and pagination
   * @param userId - Current user ID (for permission checks)
   * @param isAdmin - Whether user is admin
   * @returns Paginated list of commission ledger entries
   * @throws BadRequestException if parameters are invalid
   *
   * @example
   * const result = await service.getCommissionLedger({
   *   page: 1,
   *   limit: 20,
   *   commission_type: 'buyer_fee',
   *   status: 'pending'
   * }, userId, isAdmin);
   */
  async getCommissionLedger(
    options: ICommissionListOptions,
    userId?: number,
    isAdmin: boolean = false,
  ): Promise<IPaginatedCommissionResponse> {
    try {
      // Validate pagination
      if (options.page < 1) {
        throw new BadRequestException('Page must be greater than 0');
      }
      if (options.limit < 1 || options.limit > 100) {
        throw new BadRequestException('Limit must be between 1 and 100');
      }

      // Non-admin users can only see their own commissions
      if (!isAdmin && userId) {
        options.user_id = userId;
      }

      this.logger.debug(`Fetching commission ledger with options: ${JSON.stringify(options)}`);

      return await this.commissionRepository.getCommissionLedger(options);
    } catch (error) {
      this.logger.error(`Error fetching commission ledger: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get overall commission summary statistics
   *
   * Returns aggregated commission data across all commissions:
   * - Total amounts by type
   * - Count by status
   * - Average amounts
   *
   * Optional filtering by date range and type.
   * Admins see all commissions; users see their own.
   *
   * @param filters - Optional filters for date range, type, status
   * @param userId - Current user ID (for permission checks)
   * @param isAdmin - Whether user is admin
   * @returns Commission summary with breakdowns by type and status
   *
   * @example
   * const summary = await service.getCommissionSummary({
   *   from_date: new Date('2024-01-01'),
   *   to_date: new Date('2024-12-31')
   * }, userId, true);
   */
  async getCommissionSummary(
    filters?: ICommissionFilter,
    userId?: number,
    isAdmin: boolean = false,
  ): Promise<ICommissionSummary> {
    try {
      // Non-admin users can only see their own commissions
      if (!isAdmin && userId) {
        filters = { ...filters, user_id: userId };
      }

      this.logger.debug(`Fetching commission summary with filters: ${JSON.stringify(filters)}`);

      return await this.commissionRepository.getCommissionSummary(filters);
    } catch (error) {
      this.logger.error(`Error fetching commission summary: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get commission summary for a specific user
   *
   * Provides breakdown of all commissions for a user:
   * - Total amounts by status (pending, approved, paid)
   * - Breakdown by commission type (buyer_fee, seller_fee, etc.)
   * - Last payment date
   *
   * Non-admin users can only view their own summary.
   * Admins can view any user's summary.
   *
   * @param userId - ID of the user to get summary for
   * @param fromDate - Optional start date filter
   * @param toDate - Optional end date filter
   * @param currentUserId - Current authenticated user ID
   * @param isAdmin - Whether current user is admin
   * @returns User commission summary or null if user not found
   * @throws NotFoundException if user does not exist
   * @throws BadRequestException if user tries to access other's data without admin
   *
   * @example
   * const userSummary = await service.getUserCommissionSummary(
   *   123,
   *   undefined,
   *   undefined,
   *   123,
   *   false
   * );
   */
  async getUserCommissionSummary(
    userId: number,
    fromDate?: Date,
    toDate?: Date,
    currentUserId?: number,
    isAdmin: boolean = false,
  ): Promise<IUserCommissionSummary> {
    try {
      // Permission check: non-admin users can only view their own commissions
      if (!isAdmin && currentUserId && currentUserId !== userId) {
        throw new BadRequestException(
          'You can only view your own commission summary',
        );
      }

      // Verify user exists
      const user = await this.userRepo.findOne({ where: { id: userId } });
      if (!user) {
        throw new NotFoundException(`User with ID ${userId} not found`);
      }

      this.logger.debug(`Fetching commission summary for user ${userId}`);

      const summary = await this.commissionRepository.getUserCommissionSummary(
        userId,
        fromDate,
        toDate,
      );

      if (!summary) {
        // Return zero-value summary if user has no commissions
        return {
          user_id: userId,
          user_name: user.full_name || 'Unknown',
          user_mobile: user.mobile_number,
          user_email: user.email,
          total_commissions: 0,
          total_amount: 0,
          pending_amount: 0,
          approved_amount: 0,
          paid_amount: 0,
          commission_details: {
            buyer_fee: 0,
            seller_fee: 0,
            platform_fee: 0,
            referral_fee: 0,
          },
        };
      }

      return summary;
    } catch (error) {
      this.logger.error(`Error fetching user commission summary: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get all commissions for a specific deal
   *
   * Retrieves commission breakdown for a single deal transaction:
   * - All commission entries by type
   * - Current status and payment info
   * - Total commissions for the deal
   *
   * Non-admin users can only view commissions for deals they're involved with.
   * Admins can view any deal's commissions.
   *
   * @param dealId - ID of the deal
   * @param currentUserId - Current authenticated user ID
   * @param isAdmin - Whether current user is admin
   * @returns Deal commission summary with all entries
   * @throws NotFoundException if deal does not exist
   * @throws BadRequestException if user not involved in deal (non-admin)
   *
   * @example
   * const dealComm = await service.getDealCommissions(456, 123, false);
   */
  async getDealCommissions(
    dealId: number,
    currentUserId?: number,
    isAdmin: boolean = false,
  ): Promise<IDealCommissionSummary> {
    try {
      // Verify deal exists
      const deal = await this.dealRepo.findOne({
        where: { id: dealId },
        relations: ['buyer_user', 'seller_user'],
      });

      if (!deal) {
        throw new NotFoundException(`Deal with ID ${dealId} not found`);
      }

      // Permission check: non-admin users can only view commissions for deals they're involved with
      if (!isAdmin && currentUserId) {
        if (
          deal.buyer_user_id !== currentUserId &&
          deal.seller_user_id !== currentUserId
        ) {
          throw new BadRequestException(
            'You are not involved in this deal',
          );
        }
      }

      this.logger.debug(`Fetching commissions for deal ${dealId}`);

      return await this.commissionRepository.getDealCommissions(dealId);
    } catch (error) {
      this.logger.error(`Error fetching deal commissions: ${error.message}`);
      throw error;
    }
  }

  /**
   * Export commission data to CSV format
   *
   * Generates CSV data for commission ledger with optional filtering.
   * Each row represents one commission entry with all details.
   *
   * CSV Columns:
   * - id, deal_id, commission_type, amount, percentage_applied
   * - status, payment_date, payment_reference, notes
   * - created_date, updated_date
   *
   * Only admins can export; non-admins can only export their own.
   *
   * @param filters - Optional filters for type, status, date range
   * @param userId - Current user ID
   * @param isAdmin - Whether user is admin
   * @returns CSV-formatted string data
   * @throws BadRequestException if no data matches filters
   *
   * @example
   * const csv = await service.exportCommissionsToCSV({
   *   status: 'paid',
   *   from_date: new Date('2024-01-01')
   * }, userId, false);
   */
  async exportCommissionsToCSV(
    filters?: ICommissionFilter,
    userId?: number,
    isAdmin: boolean = false,
  ): Promise<string> {
    try {
      // Non-admin users can only export their own commissions
      if (!isAdmin && userId) {
        filters = { ...filters, user_id: userId };
      }

      this.logger.debug(`Exporting commissions to CSV with filters: ${JSON.stringify(filters)}`);

      // Fetch commissions with filters
      const options: ICommissionListOptions = {
        page: 1,
        limit: 10000, // Get all records for export
        commission_type: filters?.commission_type,
        status: filters?.status,
        deal_id: filters?.deal_id,
        user_id: filters?.user_id,
        from_date: filters?.from_date,
        to_date: filters?.to_date,
      };

      const result = await this.commissionRepository.getCommissionLedger(options);

      if (result.data.length === 0) {
        throw new BadRequestException('No commissions found matching the export criteria');
      }

      // Convert to CSV format
      const csvHeader =
        'id,deal_id,commission_type,amount,percentage_applied,status,payment_date,payment_reference,notes,created_date,updated_date\n';

      const csvRows = result.data
        .map((commission) => this.formatCommissionToCsvRow(commission))
        .join('\n');

      const csvData = csvHeader + csvRows;

      this.logger.log(
        `Exported ${result.data.length} commission records to CSV`,
      );

      return csvData;
    } catch (error) {
      this.logger.error(`Error exporting commissions to CSV: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get pending commissions (for payment processing)
   *
   * Retrieves all commissions with pending status.
   * Used for payment processing and reporting.
   *
   * @returns Array of pending commissions with deal details
   *
   * @example
   * const pending = await service.getPendingCommissions();
   */
  async getPendingCommissions(): Promise<CommissionLedger[]> {
    try {
      this.logger.debug('Fetching pending commissions');
      return await this.commissionRepository.getPendingCommissions();
    } catch (error) {
      this.logger.error(`Error fetching pending commissions: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get commission statistics and analytics
   *
   * Provides detailed analytics on commission distribution:
   * - Total deals with commissions
   * - Average commission amounts
   * - Distribution by type and status
   *
   * @returns Commission statistics and analytics
   *
   * @example
   * const stats = await service.getCommissionStatistics();
   */
  async getCommissionStatistics(): Promise<any> {
    try {
      this.logger.debug('Calculating commission statistics');

      const summary = await this.commissionRepository.getCommissionSummary();

      // Calculate additional statistics
      const dealsWithCommissions = await this.ledgerRepo
        .createQueryBuilder('cl')
        .distinct(true)
        .select('COUNT(DISTINCT cl.deal_id)', 'count')
        .getRawOne();

      const avgCommissionAmount =
        summary.total_count > 0
          ? summary.total_amount / summary.total_count
          : 0;

      return {
        total_deals_with_commissions: parseInt(dealsWithCommissions?.count || 0),
        average_deal_commission_amount: Math.round(avgCommissionAmount * 100) / 100,
        total_commission_amount: summary.total_amount,
        total_commission_entries: summary.total_count,
        pending_amount: summary.pending_amount,
        approved_amount: summary.approved_amount,
        paid_amount: summary.paid_amount,
        commission_distribution: {
          by_type: summary.by_type,
          by_status: summary.by_status,
        },
      };
    } catch (error) {
      this.logger.error(`Error calculating commission statistics: ${error.message}`);
      throw error;
    }
  }

  /**
   * Private helper method to format commission to CSV row
   *
   * Converts a commission object to a CSV-formatted row.
   * Properly escapes values and formats dates.
   *
   * @param commission - Commission ledger entry
   * @returns CSV-formatted row string
   */
  private formatCommissionToCsvRow(commission: any): string {
    const escape = (value: any): string => {
      if (value === null || value === undefined) {
        return '';
      }
      const stringValue = String(value);
      if (stringValue.includes(',') || stringValue.includes('"')) {
        return `"${stringValue.replace(/"/g, '""')}"`;
      }
      return stringValue;
    };

    const formatDate = (date: any): string => {
      if (!date) return '';
      return new Date(date).toISOString().split('T')[0];
    };

    return [
      escape(commission.id),
      escape(commission.deal_id),
      escape(commission.commission_type),
      escape(parseFloat(commission.amount)),
      escape(commission.percentage_applied || 0),
      escape(commission.status),
      escape(formatDate(commission.payment_date)),
      escape(commission.payment_reference),
      escape(commission.notes),
      escape(formatDate(commission.created_at)),
      escape(formatDate(commission.updated_at)),
    ].join(',');
  }
}
