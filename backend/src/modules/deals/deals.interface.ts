/**
 * Deals Module Interfaces and Types
 * 
 * Comprehensive TypeScript interfaces for type safety and documentation
 */

/**
 * Deal Status Type
 * - open: Deal created, awaiting closure
 * - closed: Deal finalized, commissions calculated
 */
export type DealStatus = 'open' | 'closed';

/**
 * Payment Status Type
 * - pending: Awaiting payment
 * - completed: Payment received
 */
export type PaymentStatus = 'pending' | 'completed';

/**
 * Deal Interface
 * Core deal transaction information
 */
export interface IDeal {
  id: number;
  buyer_user_id: number;
  seller_user_id: number;
  property_id?: number;
  project_id?: number;
  referral_partner_id?: number;
  created_by_admin_id?: number;
  transaction_value: number;
  status: DealStatus;
  payment_status: PaymentStatus;
  payment_date?: Date;
  commission_locked_at?: Date;
  deal_closed_at?: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * Deal Referral Mapping Interface
 * Links referral partners to deals with commission percentages
 */
export interface IDealReferralMapping {
  id: number;
  deal_id: number;
  referral_partner_id: number;
  side: 'buyer' | 'seller';
  commission_percentage: number;
  commission_locked_at?: Date;
  created_at: Date;
}

/**
 * Commission Ledger Interface
 * Tracks all commission payments and allocations
 */
export interface ICommissionLedger {
  id: number;
  deal_id: number;
  referral_partner_id?: number;
  commission_type: 'buyer_fee' | 'seller_fee' | 'platform_fee' | 'referral_fee';
  amount: number;
  percentage_applied?: number;
  status: 'pending' | 'approved' | 'paid';
  payment_date?: Date;
  payment_reference?: string;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

/**
 * Create Deal Request
 * Request body for creating a new deal
 */
export interface ICreateDealRequest {
  buyer_user_id: number;
  seller_user_id: number;
  property_id?: number;
  project_id?: number;
  transaction_value: number;
  referral_partner_id?: number;
  buyer_commission_percentage?: number;
  seller_commission_percentage?: number;
}

/**
 * Close Deal Request
 * Request body for closing a deal
 */
export interface ICloseDealRequest {
  notes?: string;
  closure_date?: string;
  verification_proof_url?: string;
}

/**
 * Commission Breakdown
 * Calculated commission details for a transaction
 */
export interface ICommissionBreakdown {
  buyerCommission: number;
  sellerCommission: number;
  referralCommission?: number;
  platformCommission: number;
  totalCommission: number;
}

/**
 * Deal Response with Details
 * Full deal information with related entities
 */
export interface IDealResponse {
  deal: IDeal;
  referral_mappings: IDealReferralMapping[];
  commission_ledgers: ICommissionLedger[];
}

/**
 * Deal List Response
 * Paginated list of deals
 */
export interface IDealListResponse {
  data: IDeal[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

/**
 * Deal List Filters
 * Filter parameters for deal listing
 */
export interface IDealListFilters {
  status?: DealStatus;
  page?: number;
  limit?: number;
}

/**
 * Create Deal Response
 * Response after deal creation
 */
export interface ICreateDealResponse {
  id: number;
  buyer_user_id: number;
  seller_user_id: number;
  property_id?: number;
  project_id?: number;
  referral_partner_id?: number;
  transaction_value: number;
  status: DealStatus;
  payment_status: PaymentStatus;
  commission_locked_at?: Date;
  buyer_commission_percentage: number;
  seller_commission_percentage: number;
  created_at: Date;
}

/**
 * Close Deal Response
 * Response after deal closure
 */
export interface ICloseDealResponse {
  deal: IDeal;
  commission_ledgers: ICommissionLedger[];
}
