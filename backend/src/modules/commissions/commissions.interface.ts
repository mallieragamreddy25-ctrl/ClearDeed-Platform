/**
 * Commissions Module - TypeScript Interfaces
 *
 * Comprehensive type definitions for commission tracking, reporting,
 * and ledger management across the ClearDeed platform.
 */

/**
 * Commission Types Enum
 * Represents the different types of commissions tracked in the system
 */
export enum CommissionType {
  BUYER_FEE = 'buyer_fee',
  SELLER_FEE = 'seller_fee',
  PLATFORM_FEE = 'platform_fee',
  REFERRAL_FEE = 'referral_fee',
}

/**
 * Commission Status Enum
 * Represents the lifecycle state of a commission entry
 */
export enum CommissionStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  PAID = 'paid',
}

/**
 * Commission Ledger Entry
 * Represents a single commission transaction in the ledger
 */
export interface ICommissionLedger {
  id: number;
  deal_id: number;
  referral_partner_id?: number;
  commission_type: CommissionType | string;
  amount: number;
  percentage_applied?: number;
  status: CommissionStatus | string;
  payment_date?: Date;
  payment_reference?: string;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

/**
 * Commission Ledger with Deal Details
 * Extended view combining commission and associated deal information
 */
export interface ICommissionLedgerWithDeal extends ICommissionLedger {
  deal: {
    id: number;
    buyer_user_id: number;
    seller_user_id: number;
    property_id?: number;
    deal_value: number;
    status: string;
  };
}

/**
 * Commission Summary by Type
 * Aggregated commission data grouped by commission type
 */
export interface ICommissionSummaryByType {
  commission_type: CommissionType | string;
  total_amount: number;
  total_count: number;
  pending_amount: number;
  pending_count: number;
  approved_amount: number;
  approved_count: number;
  paid_amount: number;
  paid_count: number;
}

/**
 * Commission Summary by Status
 * Aggregated commission data grouped by status
 */
export interface ICommissionSummaryByStatus {
  status: CommissionStatus | string;
  total_amount: number;
  total_count: number;
  average_amount: number;
}

/**
 * Overall Commission Summary
 * Complete summary of all commissions across all types and statuses
 */
export interface ICommissionSummary {
  total_amount: number;
  total_count: number;
  pending_amount: number;
  pending_count: number;
  approved_amount: number;
  approved_count: number;
  paid_amount: number;
  paid_count: number;
  by_type: ICommissionSummaryByType[];
  by_status: ICommissionSummaryByStatus[];
}

/**
 * User Commission Summary
 * Commission summary for a specific user (agent/seller)
 */
export interface IUserCommissionSummary {
  user_id: number;
  user_name: string;
  user_mobile: string;
  user_email: string;
  total_commissions: number;
  total_amount: number;
  pending_amount: number;
  approved_amount: number;
  paid_amount: number;
  commission_details: {
    buyer_fee: number;
    seller_fee: number;
    platform_fee: number;
    referral_fee: number;
  };
  last_payment_date?: Date;
}

/**
 * Deal Commission Summary
 * Commission details for a specific deal
 */
export interface IDealCommissionSummary {
  deal_id: number;
  deal_value: number;
  buyer_user_id: number;
  seller_user_id: number;
  total_commissions: number;
  commissions: {
    type: CommissionType | string;
    amount: number;
    percentage: number;
    status: CommissionStatus | string;
  }[];
}

/**
 * Paginated Commission Ledger Response
 * Standard paginated response for list endpoints
 */
export interface IPaginatedCommissionResponse {
  data: ICommissionLedgerWithDeal[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
  has_more: boolean;
}

/**
 * Commission Filter Criteria
 * Query parameters for filtering commission ledger
 */
export interface ICommissionFilter {
  commission_type?: CommissionType | string;
  status?: CommissionStatus | string;
  deal_id?: number;
  user_id?: number;
  from_date?: Date;
  to_date?: Date;
  min_amount?: number;
  max_amount?: number;
  page?: number;
  limit?: number;
}

/**
 * Commission Export Data
 * Format for CSV/Excel export of commission data
 */
export interface ICommissionExportData {
  id: number;
  deal_id: number;
  commission_type: string;
  amount: string;
  percentage_applied: string;
  status: string;
  payment_date: string;
  payment_reference: string;
  notes: string;
  created_date: string;
  updated_date: string;
}

/**
 * Commission List Query Options
 * Advanced query options for ledger retrieval
 */
export interface ICommissionListOptions {
  page: number;
  limit: number;
  commission_type?: string;
  status?: string;
  deal_id?: number;
  user_id?: number;
  from_date?: Date;
  to_date?: Date;
  sort_by?: string;
  sort_order?: 'ASC' | 'DESC';
}

/**
 * Commission Statistics
 * Statistical data about commission distribution
 */
export interface ICommissionStatistics {
  total_deals_with_commissions: number;
  average_deal_commission_amount: number;
  average_commission_percentage: number;
  commission_distribution: {
    by_type: {
      [key: string]: {
        count: number;
        amount: number;
        percentage: number;
      };
    };
    by_status: {
      [key: string]: {
        count: number;
        amount: number;
        percentage: number;
      };
    };
  };
}
