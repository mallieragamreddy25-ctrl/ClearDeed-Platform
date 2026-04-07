import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  OneToMany,
} from 'typeorm';

/**
 * User Entity - Core user table for ClearDeed platform
 * 
 * Represents a ClearDeed user with support for three roles:
 * - buyer: Looking to buy properties or invest
 * - seller: Selling properties
 * - investor: Investing in projects
 * 
 * Core Features:
 * 1. OTP-based phone authentication
 * 2. Email verification
 * 3. Profile completion workflow
 * 4. Referral system for incentives
 * 5. Active/verified status tracking
 * 6. Session management with JWT tokens
 * 
 * Database:
 * - Table: users
 * - Primary Key: id (auto-generated)
 * - Unique Keys: mobile_number, email
 * - Indexes: mobile_number, email, referral_mobile_number
 * 
 * Workflow:
 * 1. User registers with mobile number
 * 2. OTP is generated and sent via SMS
 * 3. OTP is verified and JWT token issued
 * 4. User completes profile (POST /profile)
 * 5. User account is verified and activated
 * 
 * @see IUser interface for TypeScript types
 */
@Entity('users')
@Index(['mobile_number'])
@Index(['email'])
@Index(['referral_mobile_number'])
export class User {
  /**
   * Unique user identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Mobile number (unique)
   * Format: Indian phone number (10 digits)
   * Used as primary identifier for login
   * Indexed for fast lookups during auth
   */
  @Column({ type: 'varchar', length: 20, unique: true })
  mobile_number: string;

  /**
   * OTP Hash (SHA-256)
   * Stores hashed OTP for verification
   * Cleared after OTP validation
   */
  @Column({ type: 'varchar', nullable: true })
  otp_hash: string;

  /**
   * OTP Creation Timestamp
   * Used to enforce 5-minute expiry
   */
  @Column({ type: 'timestamp', nullable: true })
  otp_created_at: Date;

  /**
   * OTP Attempt Counter
   * Incremented on each failed verification
   * Reset after successful verification
   */
  @Column({ type: 'int', default: 0 })
  otp_attempts: number;

  /**
   * OTP Lock Timestamp
   * Prevents further OTP attempts for 15 minutes
   * Set when otp_attempts reaches 5
   */
  @Column({ type: 'timestamp', nullable: true })
  otp_locked_until: Date;

  // ============================================
  // PROFILE INFORMATION
  // ============================================

  /**
   * User's full name
   * Filled during profile completion
   */
  @Column({ type: 'varchar', length: 255, nullable: true })
  full_name: string;

  /**
   * User's email address (unique)
   * Filled during profile completion
   * Validated for uniqueness during profile update
   * Indexed for search operations
   */
  @Column({ type: 'varchar', unique: true, nullable: true })
  email: string;

  /**
   * City/location of the user
   * Filled during profile completion
   * Used for property discovery filtering
   */
  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string;

  /**
   * User's selected role/profile type
   * Enum: 'buyer', 'seller', 'investor'
   * Determines available features and permissions
   * Can be changed via /profile/mode-select endpoint
   */
  @Column({
    type: 'enum',
    enum: ['buyer', 'seller', 'investor'],
    nullable: true,
  })
  profile_type: 'buyer' | 'seller' | 'investor';

  /**
   * Budget range for buyers
   * Format: "50-100 Lakhs", "1-2 Crores", etc.
   * Used for property recommendation filtering
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  budget_range: string;

  /**
   * Net worth range for investors
   * Format: "1 Crore", "10 Crores+", etc.
   * Used for investment opportunity qualification
   */
  @Column({ type: 'varchar', length: 50, nullable: true })
  net_worth_range: string;

  // ============================================
  // REFERRAL SYSTEM
  // ============================================

  /**
   * Referrer's mobile number
   * Mobile number of the person who referred this user
   * Triggers referral rewards when validated
   */
  @Column({ type: 'varchar', length: 20, nullable: true })
  referral_mobile_number: string;

  /**
   * Referral Validation Flag
   * true = referral number has been validated and is active
   * false = referral not yet validated or invalid
   * Validation rules:
   * - Referrer must be a verified user
   * - Referrer must have active status
   * - Cannot self-refer (referrer != current user)
   */
  @Column({ type: 'boolean', default: false })
  referral_validated: boolean;

  /**
   * Referred by mobile number
   * Mobile number of users referred by this user
   * Used for tracking referral tree
   */
  @Column({ type: 'varchar', length: 20, nullable: true })
  referred_by_mobile: string;

  // ============================================
  // STATUS FLAGS
  // ============================================

  /**
   * Active status flag
   * true = user account is active
   * false = user account is deactivated
   * Deactivated users cannot authenticate even with valid credentials
   * Required for login validation
   */
  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  /**
   * Verification status flag
   * true = user profile is complete and verified
   * false = profile not yet complete
   * Set to true when: full_name, email, and profile_type are filled
   * Required for accessing protected features
   */
  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  // ============================================
  // SESSION & AUTH TOKENS
  // ============================================

  /**
   * Last login timestamp
   * Updated whenever user successfully authenticates
   * Used for tracking user activity
   */
  @Column({ type: 'timestamp', nullable: true })
  last_login: Date;

  /**
   * Session token (deprecated, kept for backward compatibility)
   * JWT token issued after OTP verification
   * Should be validated against JWT_SECRET
   */
  @Column({ type: 'varchar', nullable: true })
  session_token: string;

  /**
   * Token expiry timestamp
   * Prevents token reuse after expiration
   * JWT tokens issued with 24-hour validity
   */
  @Column({ type: 'timestamp', nullable: true })
  token_expires_at: Date;

  // ============================================
  // TIMESTAMPS
  // ============================================

  /**
   * Record creation timestamp
   * Automatically set by database
   * Immutable after creation
   */
  @CreateDateColumn()
  created_at: Date;

  /**
   * Record last update timestamp
   * Automatically updated by database on each modification
   * Used for optimistic locking and audit trails
   */
  @UpdateDateColumn()
  updated_at: Date;
}
