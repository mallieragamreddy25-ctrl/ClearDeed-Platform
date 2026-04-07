/**
 * Admin Interfaces - TypeScript Types for Admin Module
 *
 * Complete set of interfaces used throughout admin module.
 * Provides type safety for API requests, responses, and internal operations.
 *
 * Interfaces:
 * - IAdminUser: Admin user profile representation
 * - IAdminActivityLog: Activity log entry
 * - IActivityLogFilter: Query filters for activity logs
 * - IActivityLogResponse: Paginated activity response
 * - IAdminSummary: Daily/weekly activity summary
 */

/**
 * IAdminUser - Admin User Profile Interface
 *
 * Represents an admin user with role and status information.
 * Safe to return in API responses.
 */
export interface IAdminUser {
  id: number;
  mobile_number: string;
  full_name: string;
  email: string;
  admin_role: 'super_admin' | 'property_verifier' | 'deal_manager' | 'commission_manager' | 'support_agent';
  is_active: boolean;
  is_suspended: boolean;
  suspended_reason?: string;
  suspended_at?: Date;
  suspended_by_user_id?: number;
  created_at: Date;
  updated_at: Date;
  created_by_user_id: number;
  last_login?: Date;
}

/**
 * IAdminActivityLog - Activity Log Entry Interface
 *
 * Represents a single admin activity log entry.
 */
export interface IAdminActivityLog {
  id: number;
  admin_user_id: number;
  admin_user?: Partial<IAdminUser>;
  action_type: string;
  related_entity_type: string;
  related_entity_id?: number;
  action_details?: Record<string, any>;
  ip_address?: string;
  created_at: Date;
}

/**
 * IActivityLogFilter - Query Filters for Activity Logs
 *
 * Filters for querying activity logs with pagination.
 */
export interface IActivityLogFilter {
  action_type?: string;
  admin_id?: number;
  related_entity_type?: string;
  start_date?: Date;
  end_date?: Date;
  page?: number;
  limit?: number;
}

/**
 * IActivityLogResponse - Paginated Activity Log Response
 *
 * Wrapper for paginated activity log results.
 */
export interface IActivityLogResponse {
  data: IAdminActivityLog[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

/**
 * IActivitySummary - Daily/Weekly Activity Summary
 *
 * Summary statistics for admin activities.
 */
export interface IActivitySummary {
  date: string;
  action_type: string;
  count: number;
}

/**
 * IActivitySummaryResponse - Activity Summary Response
 *
 * Aggregated summary data with metadata.
 */
export interface IActivitySummaryResponse {
  period: 'daily' | 'weekly';
  start_date: Date;
  end_date: Date;
  summary: IActivitySummary[];
  total_actions: number;
}

/**
 * IAdminResponse - Generic Admin API Response
 *
 * Standard response wrapper for admin endpoints.
 */
export interface IAdminResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: any;
  timestamp: Date;
}
