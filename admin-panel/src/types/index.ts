/**
 * @file TypeScript type definitions for ClearDeed Admin Panel
 */

// Common Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

// User & Auth
export interface AdminUser {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'verifier' | 'finance';
  permissions: string[];
  lastLogin?: string;
}

// Property Types
export interface Property {
  id: string;
  title: string;
  category: 'land' | 'individual_house' | 'commercial' | 'agriculture';
  location: string;
  city: string;
  price: number;
  area: number;
  sellerId: string;
  sellerName: string;
  uploadDate: string;
  status: 'pending' | 'under_review' | 'verified' | 'rejected';
  documents: Document[];
  verificationNotes?: string;
}

export interface Document {
  id: string;
  type: string;
  url: string;
  status: 'pending' | 'verified' | 'rejected';
  uploadedAt: string;
}

// Deal Types
export interface Deal {
  id: string;
  buyerId: string;
  buyerName: string;
  sellerId: string;
  sellerName: string;
  propertyId: string;
  value: number;
  buyerAgentId: string;
  buyerAgentName: string;
  sellerAgentId: string;
  sellerAgentName: string;
  status: 'created' | 'active' | 'verification_pending' | 'closed' | 'cancelled';
  createdAt: string;
  closedAt?: string;
  commissions: Commission[];
}

// Commission Types
export interface Commission {
  id: string;
  dealId: string;
  type: 'buyer_side' | 'seller_side';
  percentage: number;
  amount: number;
  recipientType: 'agent' | 'platform';
  recipientId?: string;
  recipientName?: string;
  status: 'pending' | 'approved' | 'paid';
  approvalDate?: string;
  paymentDate?: string;
  notes?: string;
}

// Agent Types
export interface Agent {
  id: string;
  name: string;
  mobile: string;
  email?: string;
  licenseNumber: string;
  agencyName: string;
  city: string;
  agentType: 'agent' | 'verified_user';
  status: 'active' | 'inactive' | 'suspended';
  commissionEnabled: boolean;
  maintenanceFee: number;
  feeStatus: 'paid' | 'pending' | 'overdue';
  lastFeePaid?: string;
  feeDueDate?: string;
  earnedCommission: number;
  createdAt: string;
}

// Activity Log Types
export interface Activity {
  id: string;
  actionType: string;
  entity: string;
  entityId: string;
  adminId: string;
  adminName: string;
  timestamp: string;
  status: 'success' | 'error';
  details?: Record<string, any>;
}

// Dashboard Metrics
export interface DashboardMetrics {
  totalProperties: number;
  verifiedProperties: number;
  activeDealsCounts: number;
  commissionPending: number;
  commissionPaid: number;
  activeAgents: number;
}

// Filter & Sort Types
export interface PropertyFilters {
  category?: string;
  city?: string;
  status?: string;
  searchTerm?: string;
}

export interface DealFilters {
  status?: string;
  city?: string;
  dateFrom?: string;
  dateTo?: string;
}

export interface AgentFilters {
  agentType?: string;
  status?: string;
  feeStatus?: string;
}

export interface CommissionFilters {
  type?: string;
  status?: string;
  dateFrom?: string;
  dateTo?: string;
}

// Form Types
export interface PropertyVerificationForm {
  propertyId: string;
  legalOwnershipVerified: boolean;
  documentsAuthentic: boolean;
  noDisputes: boolean;
  priceReasonable: boolean;
  allDocumentsProvided: boolean;
  notes: string;
}

export interface CreateDealForm {
  buyerId: string;
  sellerId: string;
  propertyId: string;
  value: number;
  buyerAgentId: string;
  sellerAgentId: string;
  buyerCommissionPercentage: number;
  sellerCommissionPercentage: number;
}

export interface RecordFeePaymentForm {
  agentId: string;
  amount: number;
  paymentMethod: 'bank_transfer' | 'cheque' | 'cash';
  referenceId: string;
  paymentDate: string;
}

// PHASE 2: Advanced Verification
export interface VerificationRule {
  id: string;
  name: string;
  description: string;
  category: 'legal' | 'financial' | 'document' | 'property';
  checks: string[];
  enabled: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface VerificationChecklist {
  id: string;
  propertyId: string;
  ruleId: string;
  checkItems: CheckItem[];
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  completedPercentage: number;
  verifierId: string;
  createdAt: string;
  updatedAt: string;
}

export interface CheckItem {
  id: string;
  name: string;
  completed: boolean;
  notes?: string;
  verifier?: string;
  timestamp?: string;
}

export interface VerificationSuggestion {
  id: string;
  propertyId: string;
  type: 'risk' | 'improvement' | 'action_required';
  message: string;
  severity: 'low' | 'medium' | 'high';
  createdAt: string;
  resolved: boolean;
}

export interface BulkVerificationOperation {
  id: string;
  type: 'verify' | 'reject' | 'reassign';
  propertyIds: string[];
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  totalItems: number;
  processedItems: number;
  startedAt: string;
  completedAt?: string;
}

// PHASE 2: Reporting & Analytics
export interface CommissionReport {
  id: string;
  agentId: string;
  agentName: string;
  period: string; // YYYY-MM
  totalDeals: number;
  totalAmount: number;
  paid: number;
  pending: number;
  breakdown: CommissionBreakdown[];
  generatedAt: string;
}

export interface CommissionBreakdown {
  type: 'buyer_side' | 'seller_side' | 'referral';
  count: number;
  amount: number;
  percentage: number;
}

export interface VerificationMetrics {
  totalProperties: number;
  verifiedCount: number;
  rejectedCount: number;
  pendingCount: number;
  averageVerificationTime: number; // days
  verificationRate: number; // percentage
  byCity: CityMetric[];
  byCategory: CategoryMetric[];
}

export interface CityMetric {
  city: string;
  total: number;
  verified: number;
  rate: number;
}

export interface CategoryMetric {
  category: string;
  total: number;
  verified: number;
  rate: number;
}

export interface DealVelocityMetrics {
  period: string;
  totalDeals: number;
  closedDeals: number;
  averageDealValue: number;
  averageDealTime: number; // days
  trend: 'up' | 'down' | 'stable';
  dailyData: DailyDealMetric[];
}

export interface DailyDealMetric {
  date: string;
  created: number;
  closed: number;
  value: number;
}

export interface RevenueMetrics {
  period: string;
  totalRevenue: number;
  commissionRevenue: number;
  feeRevenue: number;
  bySource: RevenueSource[];
  trend: number; // percentage change
}

export interface RevenueSource {
  source: string;
  amount: number;
  percentage: number;
}

export interface CustomReport {
  id: string;
  name: string;
  description: string;
  type: 'commission' | 'verification' | 'revenue' | 'agent_performance';
  filters: Record<string, any>;
  dateRange: { from: string; to: string };
  format: 'pdf' | 'csv' | 'excel';
  createdAt: string;
  createdBy: string;
}

// PHASE 2: User Management
export interface AdminUserRole {
  id: string;
  name: string;
  description: string;
  permissions: Permission[];
  createdAt: string;
  updatedAt: string;
}

export interface Permission {
  id: string;
  name: string;
  resource: string;
  action: 'create' | 'read' | 'update' | 'delete' | 'approve' | 'reject';
  description: string;
}

export interface AdminUserWithRole extends AdminUser {
  roleId: string;
  roleName: string;
  createdAt: string;
  updatedAt: string;
  isActive: boolean;
  loginAttempts: number;
  lockedUntil?: string;
}

export interface AuditLog {
  id: string;
  userId: string;
  userName: string;
  action: string;
  resource: string;
  resourceId: string;
  oldValue?: Record<string, any>;
  newValue?: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  status: 'success' | 'failure';
  timestamp: string;
}

export interface LoginHistory {
  id: string;
  userId: string;
  userName: string;
  loginTime: string;
  logoutTime?: string;
  ipAddress: string;
  userAgent: string;
  sessionDuration?: number;
}

export interface SecurityAlert {
  id: string;
  type: 'failed_login' | 'permission_change' | 'data_access' | 'deletion' | 'config_change';
  severity: 'low' | 'medium' | 'high' | 'critical';
  userId: string;
  userName: string;
  resourceId?: string;
  description: string;
  timestamp: string;
  acknowledged: boolean;
}

// PHASE 2: Settings & Configuration
export interface CommissionSettings {
  buyerSidePercentage: number;
  sellerSidePercentage: number;
  referralPercentage: number;
  platformFeePercentage: number;
  minimumCommissionAmount: number;
  updatedAt: string;
  updatedBy: string;
}

export interface VerificationSLASettings {
  propertyVerificationDays: number;
  documentVerificationDays: number;
  escalationThreshold: number;
  autoRejectionDays: number;
  updatedAt: string;
}

export interface NotificationTemplate {
  id: string;
  type: 'email' | 'sms';
  name: string;
  subject?: string;
  body: string;
  variables: string[];
  enabled: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface DocumentRequirement {
  id: string;
  name: string;
  description: string;
  category: string;
  isRequired: boolean;
  acceptedFormats: string[];
  maxSizeMB: number;
  verificationCriteria: string[];
  createdAt: string;
}

export interface UserRoleDefinition {
  id: string;
  name: string;
  description: string;
  permissions: string[];
  level: number; // 1-5, higher = more powerful
  isActive: boolean;
  createdAt: string;
}

// PHASE 2: Advanced Features
export interface GlobalSearchResult {
  id: string;
  type: 'property' | 'dealer' | 'deal' | 'agent' | 'user' | 'commission';
  title: string;
  subtitle?: string;
  description?: string;
  link: string;
  icon: string;
  score: number; // relevance score
}

export interface SavedSearchPreset {
  id: string;
  name: string;
  description?: string;
  entity: 'property' | 'deal' | 'agent' | 'commission';
  filters: Record<string, any>;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  createdAt: string;
  updatedAt: string;
}

export interface RealTimeNotification {
  id: string;
  type: 'verification_completed' | 'deal_created' | 'commission_paid' | 'alert' | 'task_assigned';
  title: string;
  message: string;
  relatedId: string;
  read: boolean;
  createdAt: string;
}

export interface BulkDealOperation {
  id: string;
  type: 'create' | 'approve' | 'close' | 'cancel';
  dealIds: string[];
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  totalItems: number;
  processedItems: number;
  startedAt: string;
  completedAt?: string;
}

export interface PaymentIntegration {
  id: string;
  provider: 'razorpay' | 'stripe';
  isActive: boolean;
  config: Record<string, string>;
  lastTestedAt?: string;
  createdAt: string;
}

export interface ScheduledReport {
  id: string;
  name: string;
  type: 'commission' | 'verification' | 'revenue' | 'agent_performance';
  frequency: 'daily' | 'weekly' | 'monthly';
  recipients: string[];
  format: 'pdf' | 'csv' | 'excel';
  isActive: boolean;
  nextRunAt: string;
  createdAt: string;
}
