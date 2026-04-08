import { Repository } from 'typeorm';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CommissionLedger } from '../../database/entities/commission-ledger.entity';
import {
  ICommissionLedgerWithDeal,
  ICommissionSummary,
  ICommissionSummaryByType,
  ICommissionSummaryByStatus,
  IUserCommissionSummary,
  IDealCommissionSummary,
  IPaginatedCommissionResponse,
  ICommissionFilter,
  ICommissionListOptions,
} from './commissions.interface';

/**
 * Commission Ledger Repository
 *
 * Custom repository providing specialized query methods for commission tracking,
 * reporting, and analysis. Extends TypeORM Repository with domain-specific queries.
 *
 * Key Methods:
 * - getCommissionLedger: Fetch paginated commission list with filters
 * - getCommissionSummary: Get aggregated commission statistics
 * - getUserCommissionSummary: Per-user commission breakdown
 * - getDealCommissions: Commissions for a specific deal
 * - getCommissionsByType: Filter by commission type
 * - getCommissionsByStatus: Filter by status
 * - getTotalCommissionAmount: Sum calculations
 */
@Injectable()
export class CommissionLedgerRepository {
  constructor(
    @InjectRepository(CommissionLedger)
    private commissionRepository: Repository<CommissionLedger>,
  ) {}

  /**
   * Get paginated commission ledger with filters and relationships
   *
   * Retrieves commission entries with associated deal information.
   * Supports filtering by type, status, date range, and amount range.
   * Returns paginated results sorted by creation date (newest first).
   *
   * @param options - Query options including pagination, filters, and sorting
   * @returns Paginated commission ledger with deal details
   *
   * @example
   * const result = await repo.getCommissionLedger({
   *   page: 1,
   *   limit: 20,
   *   commission_type: 'buyer_fee',
   *   status: 'pending'
   * });
   */
  async getCommissionLedger(
    options: ICommissionListOptions,
  ): Promise<IPaginatedCommissionResponse> {
    const {
      page = 1,
      limit = 20,
      commission_type,
      status,
      deal_id,
      user_id,
      from_date,
      to_date,
      sort_by = 'created_at',
      sort_order = 'DESC',
    } = options;

    const skip = (page - 1) * limit;

    let query = this.commissionRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.deal', 'deal')
      .leftJoinAndSelect('cl.referral_partner', 'referral_partner')
      .leftJoinAndSelect('deal.buyer_user', 'buyer')
      .leftJoinAndSelect('deal.seller_user', 'seller');

    // Apply filters
    if (commission_type) {
      query = query.andWhere('cl.commission_type = :commission_type', {
        commission_type,
      });
    }

    if (status) {
      query = query.andWhere('cl.status = :status', { status });
    }

    if (deal_id) {
      query = query.andWhere('cl.deal_id = :deal_id', { deal_id });
    }

    if (user_id) {
      query = query.andWhere(
        '(deal.buyer_user_id = :user_id OR deal.seller_user_id = :user_id)',
        { user_id },
      );
    }

    if (from_date) {
      query = query.andWhere('cl.created_at >= :from_date', {
        from_date,
      });
    }

    if (to_date) {
      query = query.andWhere('cl.created_at <= :to_date', {
        to_date,
      });
    }

    // Get total count
    const total = await query.getCount();

    // Apply sorting and pagination
    const data = await query
      .orderBy(`cl.${sort_by}`, sort_order)
      .skip(skip)
      .take(limit)
      .getMany();

    const total_pages = Math.ceil(total / limit);
    const has_more = page < total_pages;

    return {
      data: data as unknown as ICommissionLedgerWithDeal[],
      total,
      page,
      limit,
      total_pages,
      has_more,
    };
  }

  /**
   * Get overall commission summary statistics
   *
   * Returns aggregated commission data including totals by type and status.
   * Supports date range filtering.
   *
   * @param filters - Optional filters for date range, type, status
   * @returns Commission summary with breakdowns
   *
   * @example
   * const summary = await repo.getCommissionSummary({
   *   from_date: new Date('2024-01-01'),
   *   to_date: new Date('2024-12-31')
   * });
   */
  async getCommissionSummary(
    filters?: ICommissionFilter,
  ): Promise<ICommissionSummary> {
    let query = this.commissionRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.deal', 'deal');

    // Apply date filters
    if (filters?.from_date) {
      query = query.andWhere('cl.created_at >= :from_date', {
        from_date: filters.from_date,
      });
    }

    if (filters?.to_date) {
      query = query.andWhere('cl.created_at <= :to_date', {
        to_date: filters.to_date,
      });
    }

    // Get all commissions for detailed summary
    const allCommissions = await query.getMany();

    // Calculate summary
    const summary: ICommissionSummary = {
      total_amount: 0,
      total_count: allCommissions.length,
      pending_amount: 0,
      pending_count: 0,
      approved_amount: 0,
      approved_count: 0,
      paid_amount: 0,
      paid_count: 0,
      by_type: [],
      by_status: [],
    };

    // Aggregate by type
    const byType: { [key: string]: ICommissionSummaryByType } = {};

    allCommissions.forEach((commission) => {
      const amount = parseFloat(commission.amount.toString());
      const type = commission.commission_type;
      const status = commission.status;

      // Overall totals
      summary.total_amount += amount;

      // Status totals
      if (status === 'pending') {
        summary.pending_amount += amount;
        summary.pending_count++;
      } else if (status === 'approved') {
        summary.approved_amount += amount;
        summary.approved_count++;
      } else if (status === 'paid') {
        summary.paid_amount += amount;
        summary.paid_count++;
      }

      // By type aggregation
      if (!byType[type]) {
        byType[type] = {
          commission_type: type,
          total_amount: 0,
          total_count: 0,
          pending_amount: 0,
          pending_count: 0,
          approved_amount: 0,
          approved_count: 0,
          paid_amount: 0,
          paid_count: 0,
        };
      }

      byType[type].total_amount += amount;
      byType[type].total_count++;

      if (status === 'pending') {
        byType[type].pending_amount += amount;
        byType[type].pending_count++;
      } else if (status === 'approved') {
        byType[type].approved_amount += amount;
        byType[type].approved_count++;
      } else if (status === 'paid') {
        byType[type].paid_amount += amount;
        byType[type].paid_count++;
      }
    });

    summary.by_type = Object.values(byType);

    // Aggregate by status
    const byStatus: { [key: string]: ICommissionSummaryByStatus } = {
      pending: { status: 'pending', total_amount: summary.pending_amount, total_count: summary.pending_count, average_amount: 0 },
      approved: { status: 'approved', total_amount: summary.approved_amount, total_count: summary.approved_count, average_amount: 0 },
      paid: { status: 'paid', total_amount: summary.paid_amount, total_count: summary.paid_count, average_amount: 0 },
    };

    // Calculate averages
    if (byStatus.pending.total_count > 0) {
      byStatus.pending.average_amount =
        byStatus.pending.total_amount / byStatus.pending.total_count;
    }
    if (byStatus.approved.total_count > 0) {
      byStatus.approved.average_amount =
        byStatus.approved.total_amount / byStatus.approved.total_count;
    }
    if (byStatus.paid.total_count > 0) {
      byStatus.paid.average_amount =
        byStatus.paid.total_amount / byStatus.paid.total_count;
    }

    summary.by_status = Object.values(byStatus);

    return summary;
  }

  /**
   * Get commission summary for a specific user
   *
   * Retrieves all commissions (as buyer, seller, or referral partner)
   * and provides a summary breakdown by type and status.
   *
   * @param userId - ID of the user
   * @param fromDate - Optional start date filter
   * @param toDate - Optional end date filter
   * @returns User commission summary with aggregated amounts
   *
   * @example
   * const userSummary = await repo.getUserCommissionSummary(123);
   */
  async getUserCommissionSummary(
    userId: number,
    fromDate?: Date,
    toDate?: Date,
  ): Promise<IUserCommissionSummary | null> {
    let query = this.commissionRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.deal', 'deal')
      .leftJoinAndSelect('deal.buyer_user', 'buyer')
      .leftJoinAndSelect('deal.seller_user', 'seller')
      .leftJoinAndSelect('cl.referral_partner', 'referral')
      .where(
        '(deal.buyer_user_id = :userId OR deal.seller_user_id = :userId OR cl.referral_partner_id = :userId)',
        { userId },
      );

    if (fromDate) {
      query = query.andWhere('cl.created_at >= :fromDate', { fromDate });
    }

    if (toDate) {
      query = query.andWhere('cl.created_at <= :toDate', { toDate });
    }

    const commissions = await query.getMany();

    if (commissions.length === 0) {
      return null;
    }

    // Get user info
    const deal = commissions[0].deal;
    const user =
      deal.buyer_user_id === userId ? deal.buyer_user : deal.seller_user;

    // Calculate summary
    let total_amount = 0;
    let pending_amount = 0;
    let approved_amount = 0;
    let paid_amount = 0;
    const commission_details = {
      buyer_fee: 0,
      seller_fee: 0,
      platform_fee: 0,
      referral_fee: 0,
    };
    let last_payment_date: Date | undefined;

    commissions.forEach((commission) => {
      const amount = parseFloat(commission.amount.toString());
      total_amount += amount;

      if (commission.status === 'pending') {
        pending_amount += amount;
      } else if (commission.status === 'approved') {
        approved_amount += amount;
      } else if (commission.status === 'paid') {
        paid_amount += amount;
        if (
          commission.payment_date &&
          (!last_payment_date ||
            commission.payment_date > last_payment_date)
        ) {
          last_payment_date = commission.payment_date;
        }
      }

      if (commission.commission_type === 'buyer_fee') {
        commission_details.buyer_fee += amount;
      } else if (commission.commission_type === 'seller_fee') {
        commission_details.seller_fee += amount;
      } else if (commission.commission_type === 'platform_fee') {
        commission_details.platform_fee += amount;
      } else if (commission.commission_type === 'referral_fee') {
        commission_details.referral_fee += amount;
      }
    });

    return {
      user_id: userId,
      user_name: user?.full_name || 'Unknown',
      user_mobile: user?.mobile_number || 'Unknown',
      user_email: user?.email || 'Unknown',
      total_commissions: commissions.length,
      total_amount,
      pending_amount,
      approved_amount,
      paid_amount,
      commission_details,
      last_payment_date,
    };
  }

  /**
   * Get all commissions for a specific deal
   *
   * Retrieves all commission entries associated with a single deal.
   *
   * @param dealId - ID of the deal
   * @returns Array of commission ledger entries for the deal
   *
   * @example
   * const dealCommissions = await repo.getDealCommissions(456);
   */
  async getDealCommissions(dealId: number): Promise<IDealCommissionSummary> {
    const commissions = await this.commissionRepository.find({
      where: { deal_id: dealId },
      relations: ['deal'],
    });

    if (commissions.length === 0) {
      // Try to get deal info even if no commissions exist
      const deal = await this.commissionRepository.manager
        .createQueryBuilder()
        .select('deal.*')
        .from('deals', 'deal')
        .where('deal.id = :dealId', { dealId })
        .getRawOne();

      if (deal) {
        return {
          deal_id: dealId,
          deal_value: deal.deal_value || 0,
          buyer_user_id: deal.buyer_user_id,
          seller_user_id: deal.seller_user_id,
          total_commissions: 0,
          commissions: [],
        };
      }
      throw new Error(`Deal ${dealId} not found`);
    }

    const deal = commissions[0].deal;
    let total_commissions = 0;
    const commissionsDetail = commissions.map((c) => {
      const amount = parseFloat(c.amount.toString());
      total_commissions += amount;
      return {
        type: c.commission_type,
        amount,
        percentage: c.percentage_applied || 0,
        status: c.status,
      };
    });

    return {
      deal_id: dealId,
      deal_value: deal.transaction_value || 0,
      buyer_user_id: deal.buyer_user_id,
      seller_user_id: deal.seller_user_id,
      total_commissions,
      commissions: commissionsDetail,
    };
  }

  /**
   * Get commissions filtered by type
   *
   * @param type - Commission type to filter by
   * @param status - Optional status filter
   * @returns Array of commissions matching the type
   */
  async getCommissionsByType(
    type: string,
    status?: string,
  ): Promise<CommissionLedger[]> {
    const query = this.commissionRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.deal', 'deal')
      .where('cl.commission_type = :type', { type });

    if (status) {
      query.andWhere('cl.status = :status', { status });
    }

    return query.getMany();
  }

  /**
   * Get commissions filtered by status
   *
   * @param status - Commission status to filter by
   * @returns Array of commissions matching the status
   */
  async getCommissionsByStatus(status: string): Promise<CommissionLedger[]> {
    return this.commissionRepository.find({
      where: { status: status as any },
      relations: ['deal'],
    });
  }

  /**
   * Calculate total commission amount with optional filters
   *
   * @param filters - Optional filters for type, status, date range
   * @returns Total commission amount
   */
  async getTotalCommissionAmount(
    filters?: ICommissionFilter,
  ): Promise<number> {
    let query = this.commissionRepository
      .createQueryBuilder('cl')
      .select('SUM(cl.amount)', 'total');

    if (filters?.commission_type) {
      query = query.andWhere('cl.commission_type = :type', {
        type: filters.commission_type,
      });
    }

    if (filters?.status) {
      query = query.andWhere('cl.status = :status', {
        status: filters.status,
      });
    }

    if (filters?.from_date) {
      query = query.andWhere('cl.created_at >= :fromDate', {
        fromDate: filters.from_date,
      });
    }

    if (filters?.to_date) {
      query = query.andWhere('cl.created_at <= :toDate', {
        toDate: filters.to_date,
      });
    }

    const result = await query.getRawOne();
    return parseFloat(result.total || 0);
  }

  /**
   * Get pending commissions (for payment processing)
   *
   * @param limit - Optional limit on number of records to return
   * @returns Array of pending commissions
   */
  async getPendingCommissions(limit?: number): Promise<CommissionLedger[]> {
    const query = this.commissionRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.deal', 'deal')
      .leftJoinAndSelect('cl.referral_partner', 'referral')
      .where('cl.status = :status', { status: 'pending' })
      .orderBy('cl.created_at', 'ASC');

    if (limit) {
      query.take(limit);
    }

    return query.getMany();
  }
}
