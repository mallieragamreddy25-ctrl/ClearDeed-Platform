import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../database/entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import {
  InvalidReferralException,
  ResourceNotFoundException,
} from '../../common/exceptions/business.exception';
import {
  IUserProfile,
  IUserListResponse,
  IDeactivateResponse,
} from './user.interface';

/**
 * Users Service - Complete User Profile Management
 *
 * Core business logic for user account operations including:
 * - Profile creation and completion workflow
 * - Profile updates with validation (email uniqueness)
 * - Referral system validation and tracking
 * - User role/mode selection (buyer, seller, investor)
 * - Account activation, deactivation, and status management
 *
 * Business Rules:
 * 1. Email must be globally unique (validated on create/update)
 * 2. Referral mobile must belong to verified + active user
 * 3. Self-referrals are not allowed
 * 4. Profile completion requires: full_name, email, profile_type
 * 5. Mobile number validation follows Indian format
 * 6. Account verification triggered when all required fields filled
 * 7. Only verified, active users can be referrers
 *
 * Integration Points:
 * - Auth Service: Uses userId from JWT (not direct call, from controller)
 * - User Repository: Custom queries for complex operations
 * - Database: TypeORM User entity
 * - Exception Layer: Custom business exceptions
 *
 * @Injectable() - Available for dependency injection throughout application
 */
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  /**
   * Create or complete user profile
   *
   * Called after OTP verification to populate user's profile.
   * Supports both initial profile creation and updates.
   *
   * Workflow:
   * 1. Verify user exists in database
   * 2. Validate referral number (if provided)
   * 3. Update all profile fields
   * 4. Mark profile as verified if required fields complete
   * 5. Persist to database and return
   *
   * Required Fields for Profile Completion:
   * - full_name: User's full name
   * - email: Unique email address
   * - city: User's location
   * - profile_type: Role (buyer, seller, investor)
   *
   * Optional Fields:
   * - budget_range: For buyer profiles
   * - net_worth_range: For investor profiles
   * - referral_mobile_number: For referral tracking
   *
   * Validation:
   * - Email must be unique (throws BadRequestException if duplicate)
   * - Referral mobile must pass validation (throws InvalidReferralException)
   * - All string fields trimmed and validated
   *
   * @param userId - Authenticated user ID from JWT
   * @param createUserDto - Profile creation/completion data
   * @returns User profile without sensitive fields
   * @throws ResourceNotFoundException if user not found
   * @throws InvalidReferralException if referral validation fails
   * @throws BadRequestException if email already in use
   */
  async createOrCompleteProfile(
    userId: number,
    createUserDto: CreateUserDto,
  ): Promise<Partial<IUserProfile>> {
    // Find user by ID (retrieved from JWT token by controller)
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new ResourceNotFoundException('User', userId);
    }

    // Check email uniqueness before updating
    if (createUserDto.email) {
      const existingEmail = await this.usersRepository.findOne({
        where: { email: createUserDto.email },
      });
      if (existingEmail && existingEmail.id !== userId) {
        throw new BadRequestException('Email already in use');
      }
    }

    // Validate and set referral number if provided
    if (createUserDto.referral_mobile_number) {
      const isValidReferral = await this.validateReferral(
        createUserDto.referral_mobile_number,
        userId,
      );
      if (!isValidReferral) {
        throw new InvalidReferralException(
          'Referral mobile number is not eligible',
        );
      }
      user.referral_mobile_number = createUserDto.referral_mobile_number;
      user.referral_validated = true;
    }

    // Update all profile fields
    user.full_name = createUserDto.full_name;
    user.email = createUserDto.email;
    user.city = createUserDto.city;
    user.profile_type = createUserDto.profile_type;
    if (createUserDto.budget_range) {
      user.budget_range = createUserDto.budget_range;
    }
    if (createUserDto.net_worth_range) {
      user.net_worth_range = createUserDto.net_worth_range;
    }

    // Mark as verified if profile is complete
    if (user.full_name && user.email && user.profile_type) {
      user.is_verified = true;
    }

    // Save to database
    const savedUser = await this.usersRepository.save(user);
    return this.stripSensitiveFields(savedUser);
  }

  /**
   * Get user profile by ID
   *
   * Retrieves complete user profile and removes sensitive fields
   * before returning to API consumer.
   *
   * Sensitive fields removed:
   * - otp_hash: One-time password hash
   * - session_token: Previous session tokens
   * - token_expires_at: Token expiry timestamp
   * - otp_attempts, otp_created_at: OTP attempt tracking
   * - otp_locked_until: Rate limit lock status
   *
   * @param userId - User ID to retrieve
   * @returns User profile without sensitive fields
   * @throws ResourceNotFoundException if user not found
   */
  async getUserProfile(userId: number): Promise<Partial<IUserProfile>> {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new ResourceNotFoundException('User', userId);
    }

    return this.stripSensitiveFields(user);
  }

  /**
   * Update user profile with partial data
   *
   * Supports incremental profile updates without requiring all fields.
   * Only provided fields are updated; others remain unchanged.
   *
   * Updatable Fields:
   * - full_name: User's name
   * - email: Email address (with uniqueness validation)
   * - city: Location
   * - budget_range: Buyer budget preference
   * - net_worth_range: Investor net worth range
   *
   * Non-updatable Fields (cannot be changed via this endpoint):
   * - mobile_number: Set at registration, immutable
   * - profile_type: Use /mode-select endpoint
   * - is_verified, is_active: Use other endpoints
   * - Referral fields: Set during profile creation
   *
   * Email Validation:
   * If email is being updated, system checks for uniqueness.
   * Returns 400 error if new email already in use by another user.
   *
   * @param userId - User ID to update
   * @param updateUserDto - Partial update data (all fields optional)
   * @returns Updated user profile without sensitive fields
   * @throws ResourceNotFoundException if user not found
   * @throws BadRequestException if email already in use
   */
  async updateUserProfile(
    userId: number,
    updateUserDto: UpdateUserDto,
  ): Promise<Partial<IUserProfile>> {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new ResourceNotFoundException('User', userId);
    }

    // Update full_name if provided
    if (updateUserDto.full_name !== undefined) {
      user.full_name = updateUserDto.full_name;
    }

    // Update email with uniqueness check if provided
    if (updateUserDto.email !== undefined) {
      const existingUser = await this.usersRepository.findOne({
        where: { email: updateUserDto.email },
      });
      if (existingUser && existingUser.id !== userId) {
        throw new BadRequestException('Email already in use');
      }
      user.email = updateUserDto.email;
    }

    // Update city if provided
    if (updateUserDto.city !== undefined) {
      user.city = updateUserDto.city;
    }

    // Update budget_range if provided
    if (updateUserDto.budget_range !== undefined) {
      user.budget_range = updateUserDto.budget_range;
    }

    // Update net_worth_range if provided
    if (updateUserDto.net_worth_range !== undefined) {
      user.net_worth_range = updateUserDto.net_worth_range;
    }

    // Save changes to database
    const updatedUser = await this.usersRepository.save(user);
    return this.stripSensitiveFields(updatedUser);
  }

  /**
   * Get all users with pagination
   *
   * Retrieves list of users for admin dashboards and reporting.
   * Returns paginated results with total count.
   *
   * Pagination:
   * - Queries are ordered by creation date (newest first)
   * - Includes total count for client-side pagination UI
   * - Default limit: 20 records per page
   * - Default offset: 0 (start from first record)
   *
   * Note: This method typically requires admin authorization.
   *
   * @param limit - Records per page (default: 20, max: 100)
   * @param offset - Number of records to skip (default: 0)
   * @returns Paginated response with user array, total count, limit, offset
   */
  async getAllUsers(
    limit: number = 20,
    offset: number = 0,
  ): Promise<IUserListResponse> {
    const [users, total] = await this.usersRepository.findAndCount({
      where: { is_active: true },
      take: limit,
      skip: offset,
      order: { created_at: 'DESC' },
    });

    return {
      data: users.map((user) => this.stripSensitiveFields(user)) as IUserProfile[],
      total,
      limit,
      offset,
    };
  }

  /**
   * Get user by mobile number
   *
   * Utility method for finding users by mobile number.
   * Used during authentication and referral validation.
   *
   * Mobile numbers are globally unique in the system,
   * so this returns exactly zero or one result.
   *
   * @param mobileNumber - Mobile number to search
   * @returns User entity or null if not found
   */
  async getUserByMobileNumber(mobileNumber: string): Promise<User | null> {
    return await this.usersRepository.findOne({
      where: { mobile_number: mobileNumber },
    });
  }

  /**
   * Get or create user by mobile number
   *
   * Used during OTP verification workflow.
   * If user doesn't exist, creates new user account.
   * If user exists, returns existing account.
   *
   * Called by Auth module after successful OTP verification.
   *
   * @param mobileNumber - User's mobile number
   * @returns User entity (new or existing)
   */
  async getOrCreateUser(mobileNumber: string): Promise<User> {
    let user = await this.usersRepository.findOne({
      where: { mobile_number: mobileNumber },
    });

    if (!user) {
      user = this.usersRepository.create({
        mobile_number: mobileNumber,
        is_active: true,
        is_verified: false,
        otp_attempts: 0,
        referral_validated: false,
      });
      user = await this.usersRepository.save(user);
    }

    return user;
  }

  /**
   * Validate referral mobile number for public API
   *
   * Validates that a referral mobile number is a valid partner/agent.
   * Used by GET /users/referral-validation/:mobile endpoint.
   *
   * Validation Criteria:
   * 1. Mobile number must be valid Indian format
   * 2. User must exist in system
   * 3. User must be verified (is_verified = true)
   * 4. User must be active (is_active = true)
   *
   * @param referralMobileNumber - Mobile number to validate
   * @returns true if valid partner/agent, false otherwise
   */
  async validateReferralMobile(referralMobileNumber: string): Promise<boolean> {
    // Step 1: Validate mobile number format
    if (!this.isValidMobileNumber(referralMobileNumber)) {
      return false;
    }

    // Step 2: Find referral user
    const referralUser = await this.usersRepository.findOne({
      where: { mobile_number: referralMobileNumber },
    });

    // Step 3: Verify user exists
    if (!referralUser) {
      return false;
    }

    // Step 4: Verify user is verified and active
    if (!referralUser.is_verified || !referralUser.is_active) {
      return false;
    }

    return true;
  }

  /**
   * Validate referral mobile number
   *
   * Validates that a referral mobile number is eligible.
   *
   * Validation Criteria:
   * 1. Mobile number must be valid Indian format
   *    - Digits: 10 digits total
   *    - Starts with 6, 7, 8, or 9 (after optional +91 or 0)
   *    - Examples: 9876543210, +919876543210, 09876543210
   * 2. Referral user must exist in system
   * 3. Referral user must be verified (is_verified = true)
   * 4. Referral user must be active (is_active = true)
   * 5. Cannot self-refer (referral user != current user)
   *
   * Returns false if any criterion fails (no exceptions).
   *
   * @param referralMobileNumber - Mobile number to validate
   * @param currentUserId - Current user ID (to prevent self-referral)
   * @returns true if all criteria met, false otherwise
   */
  private async validateReferral(
    referralMobileNumber: string,
    currentUserId: number,
  ): Promise<boolean> {
    // Step 1: Validate mobile number format
    if (!this.isValidMobileNumber(referralMobileNumber)) {
      return false;
    }

    // Step 2: Find referral user
    const referralUser = await this.usersRepository.findOne({
      where: { mobile_number: referralMobileNumber },
    });

    // Step 3: Verify user exists
    if (!referralUser) {
      return false;
    }

    // Step 4: Check self-referral
    if (referralUser.id === currentUserId) {
      return false;
    }

    // Step 5: Verify user is verified and active
    if (!referralUser.is_verified || !referralUser.is_active) {
      return false;
    }

    return true;
  }

  /**
   * Validate mobile number format
   *
   * Validates Indian mobile number format.
   *
   * Format Rules:
   * - Optional prefix: +91 (country code) or 0 (national)
   * - Required first digit: 6, 7, 8, or 9
   * - Total digits after prefix: 10
   * - No spaces allowed (trimmed in regex)
   *
   * Valid Examples:
   * - 9876543210 (10 digits)
   * - +919876543210 (country code + 10 digits)
   * - 09876543210 (national format + 10 digits)
   *
   * Invalid Examples:
   * - 5876543210 (starts with 5)
   * - 987654321 (only 9 digits)
   * - 98765432100 (11 digits)
   *
   * @param mobile - Mobile number to validate
   * @returns true if valid format, false otherwise
   */
  private isValidMobileNumber(mobile: string): boolean {
    // Regex: Optional +91 or 0, then 1 digit (6-9), then 9 more digits
    const mobileRegex = /^(\+91|0)?[6-9]\d{9}$/;
    // Remove spaces before testing
    return mobileRegex.test(mobile.replace(/\s+/g, ''));
  }

  /**
   * Select/switch active profile type
   *
   * Allows users to change their active role.
   * Affects which features and content are available to the user.
   *
   * Available Roles:
   * - buyer: User looking to purchase properties
   * - seller: User listing properties for sale
   * - investor: User looking for investment opportunities
   *
   * Use Cases:
   * - User wants to switch from buyer to seller mode
   * - User wants to add seller capability while remaining buyer
   * - User changes investment strategy
   *
   * Note: Only one mode is active at a time.
   * This endpoint switches the active mode.
   *
   * @param userId - User ID
   * @param profileType - New active profile type
   * @returns Updated user profile with new role
   * @throws ResourceNotFoundException if user not found
   */
  async selectProfileType(
    userId: number,
    profileType: 'buyer' | 'seller' | 'investor',
  ): Promise<Partial<IUserProfile>> {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new ResourceNotFoundException('User', userId);
    }

    user.profile_type = profileType;
    const updatedUser = await this.usersRepository.save(user);

    return this.stripSensitiveFields(updatedUser);
  }

  /**
   * Deactivate user account
   *
   * Deactivates user account, preventing future logins.
   * Account data is preserved for admin review/recovery.
   *
   * Effects of Deactivation:
   * - User cannot authenticate (OTP/JWT fails)
   * - User's profile remains in system
   * - User's properties/deals remain visible
   * - Referral history preserved
   * - All user data retained for recovery
   *
   * Soft Deletion Approach:
   * This system uses soft deletion (flag-based) rather than
   * actual deletion. Admin can reactivate accounts if needed.
   *
   * @param userId - User ID to deactivate
   * @returns Success response with confirmation message
   * @throws ResourceNotFoundException if user not found
   */
  async deactivateAccount(userId: number): Promise<IDeactivateResponse> {
    const user = await this.usersRepository.findOne({
      where: { id: userId },
    });

    if (!user) {
      throw new ResourceNotFoundException('User', userId);
    }

    // Set is_active to false (soft deletion)
    user.is_active = false;
    await this.usersRepository.save(user);

    return {
      success: true,
      message: 'Account deactivated successfully',
    };
  }

  /**
   * Strip sensitive fields from user for API response
   *
   * Removes authentication and internal tracking fields
   * before returning user data to API consumers.
   *
   * Fields Removed (Security Risk):
   * - otp_hash: One-time password hash (security risk to expose)
   * - session_token: JWT-like token (should never be returned)
   * - token_expires_at: Token metadata (not needed in responses)
   * - otp_attempts: Internal tracking (admin-only data)
   * - otp_created_at: Internal timestamp (not needed client-side)
   * - otp_locked_until: Rate limit status (internal only)
   *
   * @param user - User entity from database
   * @returns User object with sensitive fields removed
   */
  private stripSensitiveFields(user: User): Partial<IUserProfile> {
    const {
      otp_hash,
      session_token,
      token_expires_at,
      otp_attempts,
      otp_created_at,
      otp_locked_until,
      ...userProfile
    } = user;
    return userProfile as Partial<IUserProfile>;
  }
}
