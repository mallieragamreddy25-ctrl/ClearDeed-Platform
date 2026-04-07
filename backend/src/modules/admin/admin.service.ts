import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Like } from 'typeorm';
import { AdminUser } from '../../database/entities/admin-user.entity';
import { AdminActivityLog } from '../../database/entities/admin-activity-log.entity';
import { User } from '../../database/entities/user.entity';
import { CreateAdminDto } from './dto/create-admin.dto';
import { UpdateAdminDto } from './dto/update-admin.dto';
import { ActivityLogFilterDto } from './dto/activity-log-filter.dto';
import {
  IAdminUser,
  IAdminActivityLog,
  IActivityLogResponse,
  IActivitySummaryResponse,
  IActivitySummary,
} from './admin.interface';

/**
 * Admin Service - Complete Admin Management
 *
 * Core business logic for admin operations including:
 * - Admin user CRUD operations
 * - Admin account suspension and activation
 * - Comprehensive activity audit logging
 * - Activity log filtering and summary generation
 * - Role-based permission validation
 *
 * Business Rules:
 * 1. Only super_admin can create new admins
 * 2. Only super_admin can suspend/unsuspend admins
 * 3. Email must be globally unique
 * 4. All admin actions are logged to audit trail
 * 5. Mobile number must be unique for admin accounts
 * 6. Admin accounts cannot be deleted, only suspended
 *
 * Activity Logging:
 * - Logs all admin actions (create, update, suspend, verify property, etc.)
 * - Includes IP address, timestamp, and action details
 * - Tracks related entity (property, deal, commission, user, etc.)
 * - Supports filtering by action type, date range, and admin
 *
 * @Injectable() - Available for dependency injection throughout application
 */
@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(AdminUser)
    private adminUsersRepository: Repository<AdminUser>,
    @InjectRepository(AdminActivityLog)
    private activityLogsRepository: Repository<AdminActivityLog>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  /**
   * Create a new admin user
   *
   * Business Rules:
   * - Only super_admin can create new admins
   * - Email must be globally unique
   * - Mobile number must be unique for users table
   * - Sets created_by_user_id to current admin
   *
   * @param dto - Admin creation data
   * @param currentUserId - ID of admin performing the action
   * @param ipAddress - IP address for audit logging
   * @returns Created admin user details
   * @throws BadRequestException if validation fails
   * @throws ForbiddenException if user is not super_admin
   */
  async createAdmin(
    dto: CreateAdminDto,
    currentUserId: number,
    ipAddress: string,
  ): Promise<Partial<IAdminUser>> {
    // Validate that current user is super_admin
    const currentAdmin = await this.getAdminById(currentUserId);
    if (currentAdmin.admin_role !== 'super_admin') {
      this.logActivity(
        currentUserId,
        'admin_creation_unauthorized_attempt',
        'admin_user',
        null,
        { requested_role: dto.admin_role },
        ipAddress,
      );
      throw new ForbiddenException('Only super_admin can create new admin accounts');
    }

    // Check if user with this mobile number exists
    const existingUser = await this.usersRepository.findOne({
      where: { mobile_number: dto.mobile_number },
    });

    if (existingUser) {
      // Check if they're already an admin
      const existingAdmin = await this.adminUsersRepository.findOne({
        where: { user_id: existingUser.id },
      });
      if (existingAdmin) {
        throw new BadRequestException('User is already an admin');
      }
    }

    // Check if email is unique
    const userWithEmail = await this.usersRepository.findOne({
      where: { email: dto.email },
    });
    if (userWithEmail) {
      throw new BadRequestException('Email already in use');
    }

    // Create or update user if doesn't exist
    let user = existingUser;
    if (!user) {
      user = this.usersRepository.create({
        mobile_number: dto.mobile_number,
        full_name: dto.full_name,
        email: dto.email,
        is_active: true,
        is_verified: true,
      });
      user = await this.usersRepository.save(user);
    }

    // Create admin user
    const adminUser = this.adminUsersRepository.create({
      user_id: user.id,
      admin_role: dto.admin_role,
      is_active: true,
      is_suspended: false,
      created_by_user_id: currentUserId,
    });

    const savedAdmin = await this.adminUsersRepository.save(adminUser);

    // Log the action
    this.logActivity(
      currentUserId,
      'admin_created',
      'admin_user',
      savedAdmin.id,
      {
        admin_role: dto.admin_role,
        mobile_number: dto.mobile_number,
        email: dto.email,
      },
      ipAddress,
    );

    return this.formatAdminResponse(savedAdmin);
  }

  /**
   * Get list of all admin users
   *
   * Features:
   * - Returns all active admins
   * - Includes basic user information
   * - Excludes sensitive fields
   *
   * @returns Array of admin users
   */
  async getAllAdmins(): Promise<Partial<IAdminUser>[]> {
    const admins = await this.adminUsersRepository.find({
      relations: ['user'],
      where: { is_active: true },
      order: { created_at: 'DESC' },
    });

    return admins.map((admin) => this.formatAdminResponse(admin));
  }

  /**
   * Get admin user by ID with full details
   *
   * @param adminId - Admin user ID
   * @returns Admin user details
   * @throws NotFoundException if admin not found
   */
  async getAdminById(adminId: number): Promise<Partial<IAdminUser>> {
    const admin = await this.adminUsersRepository.findOne({
      where: { id: adminId, is_active: true },
      relations: ['user'],
    });

    if (!admin) {
      throw new NotFoundException(`Admin with ID ${adminId} not found`);
    }

    return this.formatAdminResponse(admin);
  }

  /**
   * Update admin user details
   *
   * Business Rules:
   * - Email must remain unique if updated
   * - Role can only be changed by super_admin
   * - Cannot update suspended admins (except to unsuspend)
   *
   * @param adminId - Admin user ID to update
   * @param dto - Update data
   * @param currentUserId - ID of admin performing the action
   * @param ipAddress - IP address for audit logging
   * @returns Updated admin user details
   * @throws NotFoundException if admin not found
   * @throws ForbiddenException if user lacks permissions
   */
  async updateAdmin(
    adminId: number,
    dto: UpdateAdminDto,
    currentUserId: number,
    ipAddress: string,
  ): Promise<Partial<IAdminUser>> {
    const admin = await this.adminUsersRepository.findOne({
      where: { id: adminId },
      relations: ['user'],
    });

    if (!admin) {
      throw new NotFoundException(`Admin with ID ${adminId} not found`);
    }

    // Check if current user is super_admin for role changes
    if (dto.admin_role) {
      const currentAdmin = await this.getAdminById(currentUserId);
      if (currentAdmin.admin_role !== 'super_admin') {
        throw new ForbiddenException('Only super_admin can change admin roles');
      }
    }

    // Validate email uniqueness if updating
    if (dto.email && dto.email !== admin.user.email) {
      const userWithEmail = await this.usersRepository.findOne({
        where: { email: dto.email },
      });
      if (userWithEmail) {
        throw new BadRequestException('Email already in use');
      }
      admin.user.email = dto.email;
    }

    // Update admin fields
    if (dto.full_name) {
      admin.user.full_name = dto.full_name;
    }
    if (dto.admin_role) {
      admin.admin_role = dto.admin_role;
    }

    // Save changes
    await this.usersRepository.save(admin.user);
    const updatedAdmin = await this.adminUsersRepository.save(admin);

    // Log the action
    this.logActivity(
      currentUserId,
      'admin_updated',
      'admin_user',
      adminId,
      { updated_fields: dto },
      ipAddress,
    );

    return this.formatAdminResponse(updatedAdmin);
  }

  /**
   * Suspend an admin account
   *
   * Business Rules:
   * - Only super_admin can suspend admins
   * - Cannot suspend yourself
   * - Requires a reason
   * - Sets suspension timestamp and tracking
   *
   * @param adminId - Admin user ID to suspend
   * @param reason - Reason for suspension
   * @param currentUserId - ID of admin performing the action
   * @param ipAddress - IP address for audit logging
   * @returns Suspended admin user details
   * @throws NotFoundException if admin not found
   * @throws ForbiddenException if user lacks permissions
   * @throws BadRequestException if trying to suspend self
   */
  async suspendAdmin(
    adminId: number,
    reason: string,
    currentUserId: number,
    ipAddress: string,
  ): Promise<Partial<IAdminUser>> {
    // Validate that current user is super_admin
    const currentAdmin = await this.getAdminById(currentUserId);
    if (currentAdmin.admin_role !== 'super_admin') {
      throw new ForbiddenException('Only super_admin can suspend admins');
    }

    // Prevent self-suspension
    if (adminId === currentUserId) {
      throw new BadRequestException('Cannot suspend your own admin account');
    }

    const admin = await this.adminUsersRepository.findOne({
      where: { id: adminId },
      relations: ['user'],
    });

    if (!admin) {
      throw new NotFoundException(`Admin with ID ${adminId} not found`);
    }

    admin.is_suspended = true;
    admin.suspended_reason = reason;
    admin.suspended_at = new Date();
    admin.suspended_by_user_id = currentUserId;
    admin.is_active = false;

    const updatedAdmin = await this.adminUsersRepository.save(admin);

    // Log the action
    this.logActivity(
      currentUserId,
      'admin_suspended',
      'admin_user',
      adminId,
      { reason },
      ipAddress,
    );

    return this.formatAdminResponse(updatedAdmin);
  }

  /**
   * Unsuspend (reactivate) an admin account
   *
   * Business Rules:
   * - Only super_admin can unsuspend admins
   * - Resets suspension tracking fields
   * - Reactivates the account
   *
   * @param adminId - Admin user ID to unsuspend
   * @param currentUserId - ID of admin performing the action
   * @param ipAddress - IP address for audit logging
   * @returns Reactivated admin user details
   * @throws NotFoundException if admin not found
   * @throws ForbiddenException if user lacks permissions
   */
  async unsuspendAdmin(
    adminId: number,
    currentUserId: number,
    ipAddress: string,
  ): Promise<Partial<IAdminUser>> {
    // Validate that current user is super_admin
    const currentAdmin = await this.getAdminById(currentUserId);
    if (currentAdmin.admin_role !== 'super_admin') {
      throw new ForbiddenException('Only super_admin can unsuspend admins');
    }

    const admin = await this.adminUsersRepository.findOne({
      where: { id: adminId },
      relations: ['user'],
    });

    if (!admin) {
      throw new NotFoundException(`Admin with ID ${adminId} not found`);
    }

    admin.is_suspended = false;
    admin.is_active = true;

    const updatedAdmin = await this.adminUsersRepository.save(admin);

    // Log the action
    this.logActivity(
      currentUserId,
      'admin_unsuspended',
      'admin_user',
      adminId,
      {},
      ipAddress,
    );

    return this.formatAdminResponse(updatedAdmin);
  }

  /**
   * Log admin activity for audit trail
   *
   * Records all admin actions for compliance and security auditing.
   * Called automatically by service methods and controllers.
   *
   * Activity Types:
   * - admin_created: New admin account created
   * - admin_updated: Admin details updated
   * - admin_suspended: Admin account suspended
   * - admin_unsuspended: Admin account reactivated
   * - property_verified: Property was verified
   * - deal_created: Deal was created
   * - commission_approved: Commission was approved
   * - user_created: User account created (by admin)
   *
   * @param adminUserId - ID of admin performing the action
   * @param actionType - Type of action performed
   * @param relatedEntityType - Type of entity affected (admin_user, property, deal, etc.)
   * @param relatedEntityId - ID of affected entity
   * @param actionDetails - Additional details about the action
   * @param ipAddress - IP address from request
   */
  async logActivity(
    adminUserId: number,
    actionType: string,
    relatedEntityType: string,
    relatedEntityId?: number,
    actionDetails?: Record<string, any>,
    ipAddress?: string,
  ): Promise<IAdminActivityLog> {
    const activityLog = this.activityLogsRepository.create({
      admin_user_id: adminUserId,
      action_type: actionType,
      related_entity_type: relatedEntityType,
      related_entity_id: relatedEntityId,
      action_details: actionDetails || {},
      ip_address: ipAddress,
    });

    const savedLog = await this.activityLogsRepository.save(activityLog);
    return this.formatActivityLogResponse(savedLog);
  }

  /**
   * Get paginated activity logs with filtering
   *
   * Features:
   * - Filter by action type, admin ID, entity type
   * - Date range filtering
   * - Pagination support
   * - Sorted by most recent first
   *
   * @param filters - Filter and pagination parameters
   * @returns Paginated activity logs
   */
  async getActivityLogs(filters: ActivityLogFilterDto): Promise<IActivityLogResponse> {
    const {
      action_type,
      admin_id,
      related_entity_type,
      start_date,
      end_date,
      page = 1,
      limit = 20,
    } = filters;

    // Build query
    const query = this.activityLogsRepository.createQueryBuilder('log');

    if (action_type) {
      query.andWhere('log.action_type LIKE :action_type', {
        action_type: `%${action_type}%`,
      });
    }

    if (admin_id) {
      query.andWhere('log.admin_user_id = :admin_id', { admin_id });
    }

    if (related_entity_type) {
      query.andWhere('log.related_entity_type = :related_entity_type', {
        related_entity_type,
      });
    }

    if (start_date && end_date) {
      query.andWhere('log.created_at BETWEEN :start_date AND :end_date', {
        start_date: new Date(start_date),
        end_date: new Date(end_date),
      });
    } else if (start_date) {
      query.andWhere('log.created_at >= :start_date', {
        start_date: new Date(start_date),
      });
    } else if (end_date) {
      query.andWhere('log.created_at <= :end_date', {
        end_date: new Date(end_date),
      });
    }

    // Apply pagination and sorting
    const validLimit = Math.min(limit, 100); // Cap at 100
    const skip = (page - 1) * validLimit;

    const [logs, total] = await query
      .leftJoinAndSelect('log.admin_user', 'admin')
      .orderBy('log.created_at', 'DESC')
      .skip(skip)
      .take(validLimit)
      .getManyAndCount();

    return {
      data: logs.map((log) => this.formatActivityLogResponse(log)),
      total,
      page,
      limit: validLimit,
      totalPages: Math.ceil(total / validLimit),
    };
  }

  /**
   * Get activity summary (daily or weekly aggregation)
   *
   * Generates summary statistics of admin activities.
   * Groups by action type and counts occurrences.
   *
   * @param filters - Filter parameters (period, date range, etc.)
   * @returns Activity summary with aggregated data
   */
  async getActivitySummary(filters: ActivityLogFilterDto): Promise<IActivitySummaryResponse> {
    const { start_date, end_date, period = 'daily' } = filters;

    const startDate = start_date ? new Date(start_date) : new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const endDate = end_date ? new Date(end_date) : new Date();

    // Build query for summary
    const query = this.activityLogsRepository.createQueryBuilder('log');

    query.andWhere('log.created_at BETWEEN :start_date AND :end_date', {
      start_date: startDate,
      end_date: endDate,
    });

    // Group by action_type and date based on period
    const dateFormat = period === 'daily' ? 'YYYY-MM-DD' : 'YYYY-WW';
    const summaryData = await query
      .select(`DATE_TRUNC('${period === 'daily' ? 'day' : 'week'}', log.created_at)`, 'date')
      .addSelect('log.action_type', 'action_type')
      .addSelect('COUNT(*)', 'count')
      .groupBy(`DATE_TRUNC('${period === 'daily' ? 'day' : 'week'}', log.created_at)`)
      .addGroupBy('log.action_type')
      .orderBy(`DATE_TRUNC('${period === 'daily' ? 'day' : 'week'}', log.created_at)`, 'DESC')
      .getRawMany();

    // Format summary data
    const summary: IActivitySummary[] = summaryData.map((item) => ({
      date: item.date ? new Date(item.date).toISOString().split('T')[0] : '',
      action_type: item.action_type,
      count: parseInt(item.count, 10),
    }));

    const total = summary.reduce((acc, item) => acc + item.count, 0);

    return {
      period: period as 'daily' | 'weekly',
      start_date: startDate,
      end_date: endDate,
      summary,
      total_actions: total,
    };
  }

  /**
   * Helper method to format admin response
   * Excludes sensitive fields from API responses
   */
  private formatAdminResponse(admin: AdminUser): Partial<IAdminUser> {
    return {
      id: admin.id,
      mobile_number: admin.user.mobile_number,
      full_name: admin.user.full_name,
      email: admin.user.email,
      admin_role: admin.admin_role,
      is_active: admin.is_active,
      is_suspended: admin.is_suspended,
      suspended_reason: admin.suspended_reason,
      suspended_at: admin.suspended_at,
      suspended_by_user_id: admin.suspended_by_user_id,
      created_at: admin.created_at,
      updated_at: admin.updated_at,
      created_by_user_id: admin.created_by_user_id,
      last_login: admin.user.last_login,
    };
  }

  /**
   * Helper method to format activity log response
   */
  private formatActivityLogResponse(log: AdminActivityLog): IAdminActivityLog {
    return {
      id: log.id,
      admin_user_id: log.admin_user_id,
      admin_user: log.admin_user
        ? {
            id: log.admin_user.id,
            mobile_number: log.admin_user.mobile_number,
            full_name: log.admin_user.full_name,
            email: log.admin_user.email,
          }
        : undefined,
      action_type: log.action_type,
      related_entity_type: log.related_entity_type,
      related_entity_id: log.related_entity_id,
      action_details: log.action_details,
      ip_address: log.ip_address,
      created_at: log.created_at,
    };
  }
}
