/**
 * @file Constants and configuration for ClearDeed Admin Panel
 */

// Theme Colors
export const COLORS = {
  primary: '#003366',
  accent: '#555555',
  background: '#F5F5F5',
  white: '#FFFFFF',
  border: '#E0E0E0',
  success: '#4CAF50',
  error: '#F44336',
  warning: '#FFC107',
  info: '#2196F3',
};

// API Configuration
export const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';
export const API_TIMEOUT = 30000;

// Pagination
export const DEFAULT_PAGE_SIZE = 10;
export const PAGE_SIZE_OPTIONS = [10, 25, 50, 100];

// Status Badges
export const STATUS_COLORS = {
  // Property Verification Status
  pending: { bg: 'bg-blue-100', text: 'text-blue-800', badge: 'badge-pending' },
  under_review: { bg: 'bg-blue-100', text: 'text-blue-800', badge: 'badge-pending' },
  verified: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  rejected: { bg: 'bg-red-100', text: 'text-red-800', badge: 'badge-danger' },
  
  // Deal Status
  created: { bg: 'bg-gray-100', text: 'text-gray-800', badge: 'badge-neutral' },
  active: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  verification_pending: { bg: 'bg-yellow-100', text: 'text-yellow-800', badge: 'badge-warning' },
  closed: { bg: 'bg-gray-100', text: 'text-gray-800', badge: 'badge-neutral' },
  cancelled: { bg: 'bg-red-100', text: 'text-red-800', badge: 'badge-danger' },
  
  // Commission Status
  approved: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  paid: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  pending_commission: { bg: 'bg-yellow-100', text: 'text-yellow-800', badge: 'badge-warning' },
  
  // Agent Status
  active_agent: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  inactive: { bg: 'bg-gray-100', text: 'text-gray-800', badge: 'badge-neutral' },
  suspended: { bg: 'bg-red-100', text: 'text-red-800', badge: 'badge-danger' },
  
  // Fee Status
  paid_fee: { bg: 'bg-green-100', text: 'text-green-800', badge: 'badge-success' },
  pending_fee: { bg: 'bg-yellow-100', text: 'text-yellow-800', badge: 'badge-warning' },
  overdue: { bg: 'bg-red-100', text: 'text-red-800', badge: 'badge-danger' },
};

// Property Categories
export const PROPERTY_CATEGORIES = [
  { value: 'land', label: 'Land' },
  { value: 'individual_house', label: 'Individual House' },
  { value: 'commercial', label: 'Commercial' },
  { value: 'agriculture', label: 'Agriculture' },
];

// Cities
export const CITIES = [
  { value: 'bangalore', label: 'Bangalore' },
  { value: 'delhi', label: 'Delhi' },
  { value: 'mumbai', label: 'Mumbai' },
  { value: 'nashik', label: 'Nashik' },
  { value: 'pune', label: 'Pune' },
  { value: 'hyderabad', label: 'Hyderabad' },
];

// Agent Types
export const AGENT_TYPES = [
  { value: 'agent', label: 'Agent' },
  { value: 'verified_user', label: 'Verified User' },
];

// Commission Types
export const COMMISSION_TYPES = [
  { value: 'buyer_side', label: 'Buyer Side' },
  { value: 'seller_side', label: 'Seller Side' },
  { value: 'referral', label: 'Referral Commission' },
  { value: 'platform_fee', label: 'Platform Fee' },
];

// Payment Methods
export const PAYMENT_METHODS = [
  { value: 'bank_transfer', label: 'Bank Transfer' },
  { value: 'cheque', label: 'Cheque' },
  { value: 'cash', label: 'Cash' },
];

// Document Types
export const DOCUMENT_TYPES = [
  { value: 'title_deed', label: 'Title Deed' },
  { value: 'survey_details', label: 'Survey Details' },
  { value: 'tax_proof', label: 'Tax Proof' },
  { value: 'ownership_certificate', label: 'Ownership Certificate' },
  { value: 'other', label: 'Other' },
];

// Default Commission Percentages
export const DEFAULT_COMMISSIONS = {
  buyerSide: 2,
  sellerSide: 2,
};

// Validation Rules
export const VALIDATION = {
  minNameLength: 2,
  maxNameLength: 100,
  minPhoneLength: 10,
  maxPhoneLength: 15,
  minNotesLength: 0,
  maxNotesLength: 500,
};

// API Endpoints
export const API_ENDPOINTS = {
  // Dashboard
  dashboard: '/dashboard/metrics',
  activities: '/dashboard/activities',
  
  // Properties
  properties: '/properties',
  propertyDetail: (id: string) => `/properties/${id}`,
  propertyVerify: (id: string) => `/properties/${id}/verify`,
  
  // Deals
  deals: '/deals',
  dealDetail: (id: string) => `/deals/${id}`,
  dealCreate: '/deals',
  dealClose: (id: string) => `/deals/${id}/close`,
  
  // Agents
  agents: '/agents',
  agentDetail: (id: string) => `/agents/${id}`,
  agentMaintenance: (id: string) => `/agents/${id}/maintenance-fee`,
  
  // Commissions
  commissions: '/commissions',
  commissionApprove: (id: string) => `/commissions/${id}/approve`,
  commissionPay: (id: string) => `/commissions/${id}/pay`,
  
  // Reports
  commissionLedger: '/reports/commission-ledger',
  export: '/reports/export',
};

// Error Messages
export const ERROR_MESSAGES = {
  networkError: 'Network error. Please check your connection.',
  serverError: 'Server error. Please try again later.',
  validationError: 'Please correct the errors below.',
  notFound: 'Resource not found.',
  unauthorized: 'You are not authorized to perform this action.',
  forbidden: 'Access denied.',
  unknownError: 'An unknown error occurred. Please try again.',
};

// Success Messages
export const SUCCESS_MESSAGES = {
  propertyVerified: 'Property verified successfully.',
  propertyRejected: 'Property rejected successfully.',
  dealCreated: 'Deal created successfully.',
  dealClosed: 'Deal closed successfully.',
  commissionApproved: 'Commission approved successfully.',
  commissionPaid: 'Commission paid successfully.',
  feeRecorded: 'Fee payment recorded successfully.',
};

// Session Configuration
export const SESSION = {
  timeout: 30 * 60 * 1000, // 30 minutes
  warningTime: 5 * 60 * 1000, // 5 minutes before timeout
};

// Date Format
export const DATE_FORMAT = 'YYYY-MM-DD';
export const DATETIME_FORMAT = 'YYYY-MM-DD HH:mm:ss';

// PHASE 2: Advanced Verification
export const VERIFICATION_CATEGORIES = [
  { value: 'legal', label: 'Legal Verification' },
  { value: 'financial', label: 'Financial Verification' },
  { value: 'document', label: 'Document Verification' },
  { value: 'property', label: 'Property Verification' },
];

export const VERIFICATION_RULE_CHECKS = {
  legal: [
    'Ownership verified',
    'Title clear',
    'No disputes',
    'Possession clear',
    'Liens/mortgages cleared',
  ],
  financial: [
    'Price reasonable',
    'No outstanding dues',
    'Tax clearance',
    'Municipal clearance',
    'Water/Power connection clear',
  ],
  document: [
    'All documents provided',
    'Documents authentic',
    'Ownership in name of seller',
    'No alterations in documents',
    'Stamp duty paid',
  ],
  property: [
    'Property dimensions verified',
    'Boundary fencing intact',
    'No encroachment',
    'Construction authorized',
    'Amenities as claimed',
  ],
};

export const VERIFICATION_CHECKLIST_STATUS = [
  { value: 'pending', label: 'Pending', color: 'bg-blue-100' },
  { value: 'in_progress', label: 'In Progress', color: 'bg-yellow-100' },
  { value: 'completed', label: 'Completed', color: 'bg-green-100' },
  { value: 'failed', label: 'Failed', color: 'bg-red-100' },
];

export const BULK_OPERATION_TYPES = [
  { value: 'verify', label: 'Verify Properties' },
  { value: 'reject', label: 'Reject Properties' },
  { value: 'reassign', label: 'Reassign to Verifier' },
];

// PHASE 2: Reporting
export const REPORT_TYPES = [
  { value: 'commission', label: 'Commission Report' },
  { value: 'verification', label: 'Verification Metrics' },
  { value: 'revenue', label: 'Revenue & Profitability' },
  { value: 'agent_performance', label: 'Agent Performance' },
  { value: 'deal_velocity', label: 'Deal Velocity' },
];

export const REPORT_FORMATS = [
  { value: 'pdf', label: 'PDF' },
  { value: 'csv', label: 'CSV' },
  { value: 'excel', label: 'Excel' },
];

export const DATE_RANGES = [
  { value: '7days', label: 'Last 7 Days' },
  { value: '30days', label: 'Last 30 Days' },
  { value: '90days', label: 'Last 90 Days' },
  { value: '6months', label: 'Last 6 Months' },
  { value: 'ytd', label: 'Year to Date' },
  { value: 'custom', label: 'Custom Range' },
];

export const SCHEDULED_REPORT_FREQUENCIES = [
  { value: 'daily', label: 'Daily' },
  { value: 'weekly', label: 'Weekly' },
  { value: 'monthly', label: 'Monthly' },
];

// PHASE 2: User Management
export const USER_ROLES = [
  { value: 'admin', label: 'Admin', level: 5, description: 'Full access to all features' },
  { value: 'manager', label: 'Manager', level: 4, description: 'Manage team and reports' },
  { value: 'verifier', label: 'Verifier', level: 2, description: 'Verify properties and documents' },
  { value: 'finance', label: 'Finance', level: 3, description: 'Manage commissions and reports' },
  { value: 'agent', label: 'Agent', level: 1, description: 'Agent selling properties' },
];

export const PERMISSIONS = {
  ADMIN_MANAGEMENT: 'admin:management',
  USER_MANAGEMENT: 'user:management',
  PROPERTY_VERIFY: 'property:verify',
  PROPERTY_REJECT: 'property:reject',
  DEAL_CREATE: 'deal:create',
  DEAL_CLOSE: 'deal:close',
  COMMISSION_APPROVE: 'commission:approve',
  COMMISSION_PAY: 'commission:pay',
  REPORTS_VIEW: 'reports:view',
  SETTINGS_MANAGE: 'settings:manage',
  AUDIT_VIEW: 'audit:view',
};

export const AUDIT_ACTIONS = [
  { value: 'create', label: 'Created' },
  { value: 'update', label: 'Updated' },
  { value: 'delete', label: 'Deleted' },
  { value: 'verify', label: 'Verified' },
  { value: 'approve', label: 'Approved' },
  { value: 'reject', label: 'Rejected' },
  { value: 'pay', label: 'Paid' },
  { value: 'login', label: 'Logged In' },
  { value: 'logout', label: 'Logged Out' },
];

// PHASE 2: Settings
export const NOTIFICATION_TEMPLATE_TYPES = [
  { value: 'email', label: 'Email' },
  { value: 'sms', label: 'SMS' },
];

export const DEFAULT_NOTIFICATION_TEMPLATES = {
  propertyVerified: {
    name: 'Property Verified',
    subject: 'Your property has been verified',
    body: 'Dear {{userName}}, your property {{propertyTitle}} has been successfully verified.',
  },
  propertyRejected: {
    name: 'Property Rejected',
    subject: 'Property Verification Rejected',
    body: 'Dear {{userName}}, your property {{propertyTitle}} verification was rejected. Reason: {{reason}}',
  },
  commissionApproved: {
    name: 'Commission Approved',
    subject: 'Commission Approved for Deal {{dealId}}',
    body: 'Your commission of ₹{{amount}} has been approved.',
  },
  commissionPaid: {
    name: 'Commission Paid',
    subject: 'Commission Payment Processed',
    body: 'Your commission of ₹{{amount}} has been paid successfully.',
  },
  dealCreated: {
    name: 'Deal Created',
    subject: 'New Deal Created',
    body: 'A new deal ({{dealId}}) has been created with value ₹{{dealValue}}.',
  },
};

export const PAYMENT_PROVIDERS = [
  { value: 'razorpay', label: 'Razorpay' },
  { value: 'stripe', label: 'Stripe' },
];

// PHASE 2: Advanced Features
export const NOTIFICATION_TYPES = [
  { value: 'verification_completed', label: 'Verification Completed' },
  { value: 'deal_created', label: 'Deal Created' },
  { value: 'commission_paid', label: 'Commission Paid' },
  { value: 'alert', label: 'Alert' },
  { value: 'task_assigned', label: 'Task Assigned' },
];

export const SEARCH_ENTITY_TYPES = [
  { value: 'property', label: 'Properties' },
  { value: 'deal', label: 'Deals' },
  { value: 'agent', label: 'Agents' },
  { value: 'commission', label: 'Commissions' },
  { value: 'user', label: 'Users' },
];

// API Endpoints - PHASE 2
export const API_ENDPOINTS_PHASE2 = {
  // Advanced Verification
  verificationRules: '/verification/rules',
  verificationChecklist: '/verification/checklists',
  bulkVerification: '/verification/bulk-operation',
  verificationSuggestions: '/verification/suggestions',

  // Reports
  commissionReport: '/reports/commission',
  verificationMetrics: '/reports/verification-metrics',
  dealVelocity: '/reports/deal-velocity',
  revenueMetrics: '/reports/revenue-metrics',
  customReport: '/reports/custom',
  scheduleReport: '/reports/schedule',
  exportReport: '/reports/export',

  // User Management
  adminUsers: '/admin/users',
  adminUserRoles: '/admin/roles',
  auditLogs: '/admin/audit-logs',
  loginHistory: '/admin/login-history',
  securityAlerts: '/admin/security-alerts',

  // Settings
  commissionSettings: '/settings/commission',
  slaSettings: '/settings/sla',
  notificationTemplates: '/settings/notifications',
  documentRequirements: '/settings/documents',
  roleDefinitions: '/settings/roles',

  // Advanced Features
  globalSearch: '/search',
  savedPresets: '/search/presets',
  notifications: '/notifications',
  bulkDealOperation: '/deals/bulk-operation',
  paymentIntegration: '/payment/integration',
};
