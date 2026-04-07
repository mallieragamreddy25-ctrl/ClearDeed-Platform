/**
 * ReferralPartner Interfaces
 * 
 * TypeScript interfaces for referral partner operations
 * Used for type safety across controllers, services, and DTOs
 */

/**
 * Complete referral partner profile response
 * Used for GET detail endpoints
 */
export interface IReferralPartnerDetail {
  id: number;
  user_id?: number;
  mobile_number: string;
  partner_type: 'agent' | 'verified_user';
  full_name: string;
  email: string;
  city: string;
  agent_license_number?: string;
  agency_name?: string;
  status: 'pending' | 'under_review' | 'approved' | 'rejected';
  is_active: boolean;
  commission_enabled: boolean;
  total_commission_earned: number;
  yearly_maintenance_fee_status: string;
  maintenance_fee_renewal_date?: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * Referral partner list item response
 * Used for GET list endpoints with pagination
 */
export interface IReferralPartnerListItem {
  id: number;
  mobile_number: string;
  full_name: string;
  partner_type: 'agent' | 'verified_user';
  status: 'pending' | 'under_review' | 'approved' | 'rejected';
  is_active: boolean;
  total_commission_earned: number;
  created_at: Date;
}

/**
 * Paginated list response
 */
export interface IReferralPartnerListResponse {
  data: IReferralPartnerListItem[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

/**
 * Commission summary for a partner
 */
export interface ICommissionSummary {
  partner_id: number;
  total_earned: number;
  pending_amount: number;
  paid_amount: number;
  commission_ledger: ICommissionEntry[];
}

/**
 * Individual commission ledger entry
 */
export interface ICommissionEntry {
  id: number;
  deal_id: number;
  amount: number;
  commission_type: 'buyer_fee' | 'seller_fee' | 'platform_fee' | 'referral_fee';
  percentage_applied?: number;
  status: 'pending' | 'approved' | 'paid';
  payment_date?: Date;
  created_at: Date;
}

/**
 * Referral partner registration request
 */
export interface IRegisterReferralPartnerRequest {
  mobile_number: string;
  full_name: string;
  email: string;
  city: string;
  partner_type: 'agent' | 'verified_user';
  agent_license_number?: string;
  agency_name?: string;
}

/**
 * Referral partner update request
 */
export interface IUpdateReferralPartnerRequest {
  full_name?: string;
  email?: string;
  city?: string;
  agent_license_number?: string;
  agency_name?: string;
}

/**
 * Status transition response
 */
export interface IStatusTransitionResponse {
  id: number;
  mobile_number: string;
  previous_status: string;
  new_status: string;
  timestamp: Date;
}

/**
 * Referral partner creation response
 */
export interface ICreateReferralPartnerResponse {
  id: number;
  mobile_number: string;
  partner_type: 'agent' | 'verified_user';
  status: 'pending' | 'under_review' | 'approved' | 'rejected';
  message: string;
}

/**
 * Mobile verification response
 */
export interface IMobileVerificationResponse {
  mobile_number: string;
  is_valid_user: boolean;
  partner_exists: boolean;
  user_details?: {
    id: number;
    full_name: string;
    profile_type: string;
  };
}
