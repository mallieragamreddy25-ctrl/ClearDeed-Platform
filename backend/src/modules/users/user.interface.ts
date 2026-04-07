/**
 * User Interfaces - TypeScript Types for User Module
 *
 * Complete set of interfaces used throughout users module and related modules.
 * Provides type safety for API requests, responses, and internal operations.
 *
 * Interfaces:
 * - IUser: Complete user entity with all fields
 * - IUserProfile: Safe user response (no sensitive fields)
 * - IUserCreateRequest: Profile creation request shape
 * - IUserUpdateRequest: Profile update request shape
 * - IModeSelectRequest: Role selection request
 * - IUserListResponse: Paginated user list response
 * - IReferralValidationResult: Referral validation result
 * - IDeactivateResponse: Account deactivation response
 * - IApiResponse: Generic API response wrapper
 */

/**
 * IUser - Complete User Entity Interface
 *
 * Represents the full User database entity with all fields.
 * Includes sensitive authentication and internal tracking fields.
 * Should NOT be returned directly in API responses.
 *
 * Categories:
 * - Identity: id, mobile_number
 * - Profile: full_name, email, city, profile_type
 * - Financial: budget_range, net_worth_range
 * - Referral: referral_mobile_number, referral_validated, referred_by_mobile
 * - Authentication: otp_hash, otp_created_at, otp_attempts, otp_locked_until
 * - Session: session_token, token_expires_at, last_login
 * - Status: is_active, is_verified
 * - Metadata: created_at, updated_at
 */
export interface IUser {
  /**
   * Primary key - auto-incremented integer
   * Immutable, set by database on creation
   */
  id: number;

  /**
   * Mobile number (unique, primary login identifier)
   * Format: Indian phone numbers (10 digits)
   * Immutable after creation
   */
  mobile_number: string;

  /**
   * OTP Hash (SHA-256 encrypted)
   * Generated during OTP request, cleared after verification
   * Sensitive field - never return in API responses
   */
  otp_hash?: string;

  /**
   * OTP Creation Timestamp
   * Used to enforce 5-minute expiry
   */
  otp_created_at?: Date;

  /**
   * OTP Attempt Counter
   * Incremented on failed verification, reset on success
   * Triggers account lockout at 5 attempts
   */
  otp_attempts: number;

  /**
   * OTP Lock Timestamp
   * Prevents further OTP attempts for 15 minutes
   * Set when otp_attempts reaches 5
   */
  otp_locked_until?: Date;

  /**
   * User's full name
   * Filled during profile completion
   * Required for account verification
   */
  full_name: string;

  /**
   * User's email (unique, globally checked)
   * Used for notifications, password recovery, communication
   * Must pass email validation
   */
  email: string;

  /**
   * User's city/location
   * Used for property discovery filtering
   * Can be any location string
   */
  city: string;

  /**
   * User's active role/profile type
   * Enum: buyer, seller, investor
   * Can be switched via /profile/mode-select endpoint
   * Determines available features and content
   */
  profile_type: 'buyer' | 'seller' | 'investor';

  /**
   * Budget range string (for buyer profiles)
   * Example: "50-100 Lakhs", "1-2 Crores"
   * Optional, used for property matching
   */
  budget_range?: string;

  /**
   * Net worth range string (for investor profiles)
   * Example: "1 Crore", "10 Crores+"
   * Optional, used for investment qualification
   */
  net_worth_range?: string;

  /**
   * Referrer's mobile number
   * Mobile number of person who referred this user
   * Optional, triggers referral rewards when validated
   */
  referral_mobile_number?: string;

  /**
   * Referral Validation Status
   * true = referrer validated, rewards activated
   * false = referral not yet validated or invalid
   */
  referral_validated: boolean;

  /**
   * Referred by mobile number (reverse tracking)
   * Mobile numbers of users referred by this user
   * Used for referral tree tracking
   */
  referred_by_mobile?: string;

  /**
   * Active Status Flag
   * true = user account is active
   * false = user is deactivated (soft-deleted)
   * Deactivated users cannot authenticate
   */
  is_active: boolean;

  /**
   * Verification Status Flag
   * true = profile is complete and verified
   * false = profile not yet complete
   * Set to true when full_name, email, profile_type are filled
   */
  is_verified: boolean;

  /**
   * Last Login Timestamp
   * Updated on successful authentication
   * Used for activity tracking and security monitoring
   */
  last_login?: Date;

  /**
   * Session token (deprecated/legacy field)
   * Kept for backward compatibility
   * Use JWT tokens instead
   */
  session_token?: string;

  /**
   * Token Expiry Timestamp
   * Prevents token reuse after expiration
   * JWT tokens issued with 24-hour validity
   */
  token_expires_at?: Date;

  /**
   * Record Creation Timestamp
   * Auto-set by database, immutable
   * Used for user analytics and activity tracking
   */
  created_at: Date;

  /**
   * Record Last Update Timestamp
   * Auto-updated by database on each modification
   * Used for optimistic locking and audit trails
   */
  updated_at: Date;
}

/**
 * IUserProfile - Safe User Response Interface
 *
 * User entity with sensitive fields removed.
 * Safe to return in HTTP API responses.
 *
 * Excluded Fields (Security):
 * - otp_hash: One-time password
 * - session_token: Session authentication token
 * - token_expires_at: Token expiry data
 * - otp_related fields: Authentication internals
 *
 * This extends IUser but with optional sensitive fields.
 */
export interface IUserProfile {
  id: number;
  mobile_number: string;
  full_name: string;
  email: string;
  city: string;
  profile_type: 'buyer' | 'seller' | 'investor';
  budget_range?: string;
  net_worth_range?: string;
  referral_mobile_number?: string;
  referral_validated: boolean;
  referred_by_mobile?: string;
  is_active: boolean;
  is_verified: boolean;
  last_login?: Date;
  created_at: Date;
  updated_at: Date;
}

/**
 * IUserCreateRequest - Profile Creation Request
 *
 * Request body shape for POST /v1/users/profile
 * Sent after OTP verification to complete profile
 */
export interface IUserCreateRequest {
  full_name: string;
  email: string;
  city: string;
  profile_type: 'buyer' | 'seller' | 'investor';
  budget_range?: string;
  net_worth_range?: string;
  referral_mobile_number?: string;
}

/**
 * IUserUpdateRequest - Profile Update Request
 *
 * Request body shape for PUT /v1/users/profile
 * All fields optional for partial updates
 */
export interface IUserUpdateRequest {
  full_name?: string;
  email?: string;
  city?: string;
  budget_range?: string;
  net_worth_range?: string;
}

/**
 * IModeSelectRequest - Role/Mode Selection Request
 *
 * Request body shape for POST /v1/users/profile/mode-select
 * Switches user's active profile type
 */
export interface IModeSelectRequest {
  /**
   * New active role: buyer, seller, or investor
   * Only one role active at a time
   * Can be switched anytime by user
   */
  role: 'buyer' | 'seller' | 'investor';
}

/**
 * IUserListResponse - Paginated User List Response
 *
 * Response from admin endpoints listing users
 * Includes pagination metadata
 */
export interface IUserListResponse {
  /**
   * Array of user profiles (without sensitive fields)
   */
  data: IUserProfile[];

  /**
   * Total count of all records (for pagination calculation)
   */
  total: number;

  /**
   * Records per page limit used in query
   */
  limit: number;

  /**
   * Number of records skipped (offset)
   */
  offset: number;
}

/**
 * IReferralValidationResult - Referral Validation Result
 *
 * Response from referral validation operations
 */
export interface IReferralValidationResult {
  /**
   * Validation passed/failed
   */
  valid: boolean;

  /**
   * Human-readable validation message
   * Explains why validation passed or failed
   */
  message?: string;
}

/**
 * IApiResponse - Generic API Response Wrapper
 *
 * Wraps all API responses with standard structure
 * Used for consistent error/success responses
 */
export interface IApiResponse<T> {
  /**
   * HTTP status code (200, 400, 401, 404, 500, etc.)
   */
  statusCode: number;

  /**
   * Human-readable message
   */
  message: string;

  /**
   * Response data (if successful)
   */
  data?: T;

  /**
   * Error details (if failed)
   */
  error?: any;
}

/**
 * IDeactivateResponse - Account Deactivation Response
 *
 * Response from account deactivation endpoint
 * Confirms account has been deactivated
 */
export interface IDeactivateResponse {
  /**
   * Operation success status
   */
  success: boolean;

  /**
   * Confirmation message
   */
  message: string;
}

