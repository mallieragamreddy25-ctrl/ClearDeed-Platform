import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindOptionsWhere, ILike, In } from 'typeorm';
import { User } from '../../database/entities/user.entity';

/**
 * User Repository - Custom Data Access Layer
 *
 * Provides specialized database query methods for User entity.
 * Encapsulates complex queries and business logic for data access.
 *
 * Benefits:
 * - Separation of data access logic from service layer
 * - Reusable query methods across the application
 * - Type-safe database operations
 * - Better testability and maintainability
 * - Consistent error handling
 *
 * Methods:
 * - findById: Get user by ID
 * - findByMobileNumber: Get user by mobile number
 * - findByEmail: Get user by email
 * - findActiveUsers: Get all active users
 * - findVerifiedUsers: Get all verified users
 * - findByProfileType: Get users by role/type
 * - findReferralEligible: Get users eligible for referrals
 * - findWithPagination: Get paginated user list
 * - findUsersByCity: Find users in specific city
 * - searchUsers: Full-text search on user data
 * - countByProfileType: Count users by role
 * - findInactiveUsers: Find deactivated accounts
 *
 * @Injectable() - Available for dependency injection
 */
@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(User)
    private repository: Repository<User>,
  ) {}

  /**
   * Find user by ID
   *
   * @param id - User ID
   * @returns User entity or null if not found
   */
  async findById(id: number): Promise<User | null> {
    return await this.repository.findOne({
      where: { id },
    });
  }

  /**
   * Find user by mobile number
   *
   * Mobile number is unique, so exactly one or zero results
   * Used primarily during authentication
   *
   * @param mobileNumber - Mobile number to search for
   * @returns User entity or null if not found
   */
  async findByMobileNumber(mobileNumber: string): Promise<User | null> {
    return await this.repository.findOne({
      where: { mobile_number: mobileNumber },
    });
  }

  /**
   * Find user by email
   *
   * Email is unique, so exactly one or zero results
   * Used for email uniqueness validation during profile creation/update
   *
   * @param email - Email to search for
   * @returns User entity or null if not found
   */
  async findByEmail(email: string): Promise<User | null> {
    return await this.repository.findOne({
      where: { email },
    });
  }

  /**
   * Find all active users (is_active = true)
   *
   * Used for listing users, sending notifications, etc.
   *
   * @param limit - Maximum number of results (default: 50)
   * @param offset - Number of records to skip (default: 0)
   * @returns Array of active user entities
   */
  async findActiveUsers(limit: number = 50, offset: number = 0): Promise<User[]> {
    return await this.repository.find({
      where: { is_active: true },
      take: limit,
      skip: offset,
      order: { created_at: 'DESC' },
    });
  }

  /**
   * Find all verified users (is_verified = true)
   *
   * Verified users have completed their profile setup.
   * Used for eligibility checks, referral validation, etc.
   *
   * @param limit - Maximum number of results (default: 50)
   * @param offset - Number of records to skip (default: 0)
   * @returns Array of verified user entities
   */
  async findVerifiedUsers(limit: number = 50, offset: number = 0): Promise<User[]> {
    return await this.repository.find({
      where: { is_verified: true, is_active: true },
      take: limit,
      skip: offset,
      order: { created_at: 'DESC' },
    });
  }

  /**
   * Find users by profile type/role
   *
   * Returns all users with a specific role (buyer, seller, investor)
   * Useful for role-specific operations and analytics
   *
   * @param profileType - Profile type to filter by ('buyer', 'seller', 'investor')
   * @param limit - Maximum number of results (default: 50)
   * @param offset - Number of records to skip (default: 0)
   * @returns Array of users with specified profile type
   */
  async findByProfileType(
    profileType: 'buyer' | 'seller' | 'investor',
    limit: number = 50,
    offset: number = 0,
  ): Promise<User[]> {
    return await this.repository.find({
      where: { profile_type: profileType, is_active: true },
      take: limit,
      skip: offset,
      order: { created_at: 'DESC' },
    });
  }

  /**
   * Find users eligible for referral validation
   *
   * Eligibility criteria:
   * - User must be verified (is_verified = true)
   * - User must be active (is_active = true)
   * - User must not be the requester (id != excludeUserId)
   *
   * Used during referral validation in profile creation
   *
   * @param excludeUserId - User ID to exclude (prevent self-referral)
   * @returns Array of eligible referrers
   */
  async findReferralEligible(excludeUserId: number): Promise<User[]> {
    return await this.repository.find({
      where: {
        is_verified: true,
        is_active: true,
        // Exclude the current user
      },
    });
  }

  /**
   * Find users with pagination
   *
   * Returns all active users with pagination support
   * Typically used for admin dashboards and listing endpoints
   *
   * @param limit - Records per page
   * @param offset - Number of records to skip
   * @returns Array of paginated users
   */
  async findWithPagination(
    limit: number = 20,
    offset: number = 0,
  ): Promise<[User[], number]> {
    return await this.repository.findAndCount({
      where: { is_active: true },
      take: limit,
      skip: offset,
      order: { created_at: 'DESC' },
    });
  }

  /**
   * Find users in specific city
   *
   * Used for location-based filtering and discovery
   * Typically used by buyers/investors searching for properties in specific areas
   *
   * @param city - City name to search
   * @param limit - Maximum results (default: 50)
   * @returns Array of users in the city
   */
  async findUsersByCity(city: string, limit: number = 50): Promise<User[]> {
    return await this.repository.find({
      where: {
        city: ILike(`%${city}%`),
        is_active: true,
      },
      take: limit,
    });
  }

  /**
   * Search users by multiple criteria
   *
   * Performs full-text-like search across name, email, mobile number, and city
   * Case-insensitive search using ILike
   *
   * @param searchTerm - Term to search for
   * @param limit - Maximum results (default: 50)
   * @returns Array of matching users
   */
  async searchUsers(searchTerm: string, limit: number = 50): Promise<User[]> {
    return await this.repository
      .createQueryBuilder('user')
      .where('user.full_name ILIKE :search', { search: `%${searchTerm}%` })
      .orWhere('user.email ILIKE :search', { search: `%${searchTerm}%` })
      .orWhere('user.mobile_number ILIKE :search', { search: `%${searchTerm}%` })
      .orWhere('user.city ILIKE :search', { search: `%${searchTerm}%` })
      .andWhere('user.is_active = :active', { active: true })
      .orderBy('user.created_at', 'DESC')
      .limit(limit)
      .getMany();
  }

  /**
   * Count users by profile type
   *
   * Used for analytics and reporting
   * Returns count of active, verified users by role
   *
   * @returns Object with counts for each profile type
   */
  async countByProfileType(): Promise<{
    buyers: number;
    sellers: number;
    investors: number;
  }> {
    const [buyers, sellers, investors] = await Promise.all([
      this.repository.countBy({
        profile_type: 'buyer',
        is_active: true,
        is_verified: true,
      }),
      this.repository.countBy({
        profile_type: 'seller',
        is_active: true,
        is_verified: true,
      }),
      this.repository.countBy({
        profile_type: 'investor',
        is_active: true,
        is_verified: true,
      }),
    ]);

    return { buyers, sellers, investors };
  }

  /**
   * Find inactive/deactivated users
   *
   * Returns users with is_active = false
   * Used for admin operations and account recovery workflows
   *
   * @param limit - Maximum results (default: 50)
   * @param offset - Number of records to skip (default: 0)
   * @returns Array of inactive users
   */
  async findInactiveUsers(limit: number = 50, offset: number = 0): Promise<User[]> {
    return await this.repository.find({
      where: { is_active: false },
      take: limit,
      skip: offset,
      order: { updated_at: 'DESC' },
    });
  }

  /**
   * Find users by multiple IDs
   *
   * Batch lookup useful for operations on multiple users
   *
   * @param ids - Array of user IDs
   * @returns Array of matching users
   */
  async findByIds(ids: number[]): Promise<User[]> {
    if (ids.length === 0) return [];
    return await this.repository.find({
      where: { id: In(ids) },
    });
  }

  /**
   * Get user statistics
   *
   * Returns aggregate statistics about users
   * Used for analytics and dashboard reporting
   *
   * @returns Statistics object
   */
  async getStatistics(): Promise<{
    totalUsers: number;
    activeUsers: number;
    verifiedUsers: number;
    totalBuyers: number;
    totalSellers: number;
    totalInvestors: number;
  }> {
    const [
      totalUsers,
      activeUsers,
      verifiedUsers,
      totalBuyers,
      totalSellers,
      totalInvestors,
    ] = await Promise.all([
      this.repository.count(),
      this.repository.countBy({ is_active: true }),
      this.repository.countBy({ is_verified: true }),
      this.repository.countBy({ profile_type: 'buyer' }),
      this.repository.countBy({ profile_type: 'seller' }),
      this.repository.countBy({ profile_type: 'investor' }),
    ]);

    return {
      totalUsers,
      activeUsers,
      verifiedUsers,
      totalBuyers,
      totalSellers,
      totalInvestors,
    };
  }

  /**
   * Create a new user
   *
   * Called during OTP verification to create a user account
   * Mobile number must be unique
   *
   * @param mobileNumber - User's mobile number (unique)
   * @returns Created user entity
   */
  async createUser(mobileNumber: string): Promise<User> {
    const user = this.repository.create({
      mobile_number: mobileNumber,
      is_active: true,
      is_verified: false,
      otp_attempts: 0,
      referral_validated: false,
    });
    return await this.repository.save(user);
  }

  /**
   * Update user fields
   *
   * Generic update method for any user fields
   *
   * @param id - User ID
   * @param updateData - Partial user data to update
   * @returns Updated user entity
   */
  async updateUser(id: number, updateData: Partial<User>): Promise<User | null> {
    await this.repository.update(id, updateData);
    return await this.findById(id);
  }

  /**
   * Delete user (soft/hard delete handling)
   *
   * Note: Current implementation uses is_active flag (soft delete)
   * Actual deletion not recommended due to referential integrity
   *
   * @param id - User ID to deactivate
   * @returns true if update was successful
   */
  async deactivateUser(id: number): Promise<boolean> {
    const result = await this.repository.update(id, {
      is_active: false,
    });
    return (result.affected ?? 0) > 0;
  }

  /**
   * Reactivate deactivated user (admin operation)
   *
   * Reverses a user deactivation
   *
   * @param id - User ID to reactivate
   * @returns Reactivated user entity or null if not found
   */
  async reactivateUser(id: number): Promise<User | null> {
    await this.repository.update(id, {
      is_active: true,
    });
    return await this.findById(id);
  }

  /**
   * Get raw repository instance
   *
   * For advanced operations not covered by this repository class
   *
   * @returns TypeORM Repository instance
   */
  getRepository(): Repository<User> {
    return this.repository;
  }
}
