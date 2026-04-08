import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  BadRequestException,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiBody,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiBadRequestResponse,
  ApiUnauthorizedResponse,
  ApiNotFoundResponse,
  ApiForbiddenResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { AdminService } from './admin.service';
import { CreateAdminDto } from './dto/create-admin.dto';
import { UpdateAdminDto } from './dto/update-admin.dto';
import { ActivityLogFilterDto } from './dto/activity-log-filter.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';
import { IAdminUser, IAdminActivityLog, IActivityLogResponse, IActivitySummaryResponse } from './admin.interface';

/**
 * Admin Controller - Complete Admin Management REST API
 *
 * REST API endpoints for admin operations.
 * All endpoints require JWT Bearer token authentication from admin users.
 *
 * Endpoints:
 * - GET /admin/users - List all admin users
 * - POST /admin/users - Create new admin user (super_admin only)
 * - GET /admin/users/:id - Get admin details
 * - PUT /admin/users/:id - Update admin user
 * - POST /admin/users/:id/suspend - Suspend admin account (super_admin only)
 * - POST /admin/users/:id/unsuspend - Reactivate admin account (super_admin only)
 * - GET /admin/activity-logs - Get paginated activity logs with filters
 * - GET /admin/activity-logs/summary - Get activity summary (daily/weekly)
 *
 * Security:
 * - All endpoints require JWT authentication
 * - Most endpoints require admin role via AdminGuard
 * - Create/suspend operations require super_admin role
 * - IP address tracked for audit logging
 *
 * Error Handling:
 * - 400: Validation errors, duplicate data
 * - 401: Missing/invalid JWT token
 * - 403: Insufficient permissions
 * - 404: Resource not found
 *
 * Audit Logging:
 * - All admin actions automatically logged
 * - Includes IP address, timestamp, and action details
 * - Accessible via /activity-logs endpoint
 */
@ApiTags('Admin')
@ApiBearerAuth()
@Controller('admin')
@UseGuards(JwtAuthGuard, AdminGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  /**
   * List all admin users
   *
   * Returns a list of all active admin users with their details.
   * Available to all authenticated admins.
   *
   * @param req - Express request with authenticated user
   * @returns Array of admin users
   * @throws 401 Unauthorized if token is invalid/expired
   * @throws 403 Forbidden if user is not an admin
   */
  @Get('users')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'List all admin users',
    description: 'Returns a list of all active admin users with their details',
  })
  @ApiOkResponse({
    description: 'Admin users retrieved successfully',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'number' },
          mobile_number: { type: 'string' },
          full_name: { type: 'string' },
          email: { type: 'string' },
          admin_role: { type: 'string' },
          is_active: { type: 'boolean' },
          is_suspended: { type: 'boolean' },
          created_at: { type: 'string', format: 'date-time' },
        },
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not an admin' })
  async listAdmins(@Request() req: any): Promise<Partial<IAdminUser>[]> {
    return await this.adminService.getAllAdmins();
  }

  /**
   * Create a new admin user
   *
   * Creates a new admin account with specified role.
   * Only super_admin users can create new admin accounts.
   *
   * Business Rules:
   * - Caller must be super_admin
   * - Email must be globally unique
   * - Mobile number must be unique (or existing user)
   * - All required fields must be provided
   *
   * @param dto - Admin creation data
   * @param req - Express request with authenticated user
   * @returns Created admin user details
   * @throws 400 Bad Request if validation fails (duplicate email, etc.)
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not super_admin
   */
  @Post('users')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new admin user',
    description: 'Creates a new admin account. Only super_admin can perform this action.',
  })
  @ApiBody({
    type: CreateAdminDto,
    description: 'Admin creation request data',
  })
  @ApiCreatedResponse({
    description: 'Admin user created successfully',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'number' },
        mobile_number: { type: 'string' },
        full_name: { type: 'string' },
        email: { type: 'string' },
        admin_role: { type: 'string' },
        is_active: { type: 'boolean' },
        created_at: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiBadRequestResponse({
    description: 'Validation failed - duplicate email/mobile, invalid data',
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not super_admin' })
  async createAdmin(@Body() dto: CreateAdminDto, @Request() req: any): Promise<Partial<IAdminUser>> {
    const userId = req.user.userId;
    const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';

    return await this.adminService.createAdmin(dto, userId, ipAddress);
  }

  /**
   * Get admin user details
   *
   * Returns complete details of a specific admin user.
   * Available to all authenticated admins.
   *
   * @param id - Admin user ID
   * @param req - Express request with authenticated user
   * @returns Admin user details
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not an admin
   * @throws 404 Not Found if admin does not exist
   */
  @Get('users/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get admin user details',
    description: 'Returns complete details of a specific admin user',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID',
    example: 1,
  })
  @ApiOkResponse({
    description: 'Admin user retrieved successfully',
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not an admin' })
  @ApiNotFoundResponse({ description: 'Admin user not found' })
  async getAdmin(@Param('id') id: number, @Request() req: any): Promise<Partial<IAdminUser>> {
    const adminId = parseInt(id.toString(), 10);
    if (isNaN(adminId)) {
      throw new BadRequestException('Invalid admin ID');
    }

    return await this.adminService.getAdminById(adminId);
  }

  /**
   * Update admin user details
   *
   * Updates admin profile information or role.
   * Only super_admin can change roles.
   *
   * Available fields to update:
   * - full_name: Admin's full name
   * - email: Admin's email address
   * - admin_role: Role (requires super_admin)
   *
   * @param id - Admin user ID to update
   * @param dto - Update data (all fields optional)
   * @param req - Express request with authenticated user
   * @returns Updated admin user details
   * @throws 400 Bad Request if validation fails
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user lacks permissions
   * @throws 404 Not Found if admin does not exist
   */
  @Put('users/:id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update admin user details',
    description:
      'Updates admin profile information or role. Role changes require super_admin.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID to update',
    example: 2,
  })
  @ApiBody({
    type: UpdateAdminDto,
    description: 'Admin update request data (all fields optional)',
  })
  @ApiOkResponse({
    description: 'Admin user updated successfully',
  })
  @ApiBadRequestResponse({
    description: 'Validation failed - duplicate email, invalid role',
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({
    description: 'Forbidden - User lacks permissions to perform this action',
  })
  @ApiNotFoundResponse({ description: 'Admin user not found' })
  async updateAdmin(
    @Param('id') id: number,
    @Body() dto: UpdateAdminDto,
    @Request() req: any,
  ): Promise<Partial<IAdminUser>> {
    const adminId = parseInt(id.toString(), 10);
    if (isNaN(adminId)) {
      throw new BadRequestException('Invalid admin ID');
    }

    const userId = req.user.userId;
    const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';

    return await this.adminService.updateAdmin(adminId, dto, userId, ipAddress);
  }

  /**
   * Suspend admin account
   *
   * Suspends an admin account, preventing login and actions.
   * Only super_admin can suspend other admins.
   * Cannot suspend yourself.
   *
   * Business Rules:
   * - Caller must be super_admin
   * - Cannot suspend yourself
   * - Requires a reason for suspension
   * - Sets suspension timestamp and tracking
   *
   * @param id - Admin user ID to suspend
   * @param body - Request body with suspension reason
   * @param req - Express request with authenticated user
   * @returns Suspended admin user details
   * @throws 400 Bad Request if trying to suspend self
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not super_admin
   * @throws 404 Not Found if admin does not exist
   */
  @Post('users/:id/suspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Suspend admin account',
    description:
      'Suspends an admin account. Only super_admin can suspend other admins. Cannot suspend yourself.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID to suspend',
    example: 3,
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        reason: {
          type: 'string',
          description: 'Reason for suspension',
          example: 'Security concern - unauthorized access detected',
        },
      },
      required: ['reason'],
    },
  })
  @ApiOkResponse({
    description: 'Admin account suspended successfully',
  })
  @ApiBadRequestResponse({
    description:
      'Invalid request - missing reason, attempting to suspend self, invalid admin ID',
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({
    description: 'Forbidden - User is not super_admin or cannot suspend self',
  })
  @ApiNotFoundResponse({ description: 'Admin user not found' })
  async suspendAdmin(
    @Param('id') id: number,
    @Body() body: { reason: string },
    @Request() req: any,
  ): Promise<Partial<IAdminUser>> {
    const adminId = parseInt(id.toString(), 10);
    if (isNaN(adminId)) {
      throw new BadRequestException('Invalid admin ID');
    }

    if (!body.reason || body.reason.trim().length === 0) {
      throw new BadRequestException('Suspension reason is required');
    }

    const userId = req.user.userId;
    const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';

    return await this.adminService.suspendAdmin(adminId, body.reason, userId, ipAddress);
  }

  /**
   * Unsuspend (reactivate) admin account
   *
   * Reactivates a suspended admin account.
   * Only super_admin can unsuspend admins.
   *
   * @param id - Admin user ID to unsuspend
   * @param req - Express request with authenticated user
   * @returns Reactivated admin user details
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not super_admin
   * @throws 404 Not Found if admin does not exist
   */
  @Post('users/:id/unsuspend')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Unsuspend admin account',
    description: 'Reactivates a suspended admin account. Only super_admin can perform this.',
  })
  @ApiParam({
    name: 'id',
    description: 'Admin user ID to unsuspend',
    example: 3,
  })
  @ApiOkResponse({
    description: 'Admin account reactivated successfully',
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not super_admin' })
  @ApiNotFoundResponse({ description: 'Admin user not found' })
  async unsuspendAdmin(@Param('id') id: number, @Request() req: any): Promise<Partial<IAdminUser>> {
    const adminId = parseInt(id.toString(), 10);
    if (isNaN(adminId)) {
      throw new BadRequestException('Invalid admin ID');
    }

    const userId = req.user.userId;
    const ipAddress = req.ip || req.connection.remoteAddress || 'unknown';

    return await this.adminService.unsuspendAdmin(adminId, userId, ipAddress);
  }

  /**
   * Get activity logs with pagination and filters
   *
   * Returns paginated audit trail of admin activities.
   * Supports filtering by:
   * - action_type: Type of action performed
   * - admin_id: ID of admin who performed action
   * - related_entity_type: Type of entity affected
   * - start_date, end_date: Date range (ISO 8601)
   * - page: Page number (1-indexed)
   * - limit: Records per page (1-100, default 20)
   *
   * Activity Types:
   * - admin_created: New admin account created
   * - admin_updated: Admin details updated
   * - admin_suspended: Admin account suspended
   * - admin_unsuspended: Admin account reactivated
   * - property_verified: Property was verified
   * - deal_created: Deal was created
   * - commission_approved: Commission was approved
   * - user_created: User account created
   *
   * @param filters - Filter and pagination parameters
   * @param req - Express request with authenticated user
   * @returns Paginated activity logs with metadata
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not an admin
   */
  @Get('activity-logs')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get activity logs with pagination and filters',
    description:
      'Returns paginated audit trail of admin activities. Supports filtering by action type, admin ID, date range, and entity type.',
  })
  @ApiQuery({
    name: 'action_type',
    required: false,
    description: 'Filter by action type (e.g., admin_created, property_verified)',
  })
  @ApiQuery({
    name: 'admin_id',
    type: Number,
    required: false,
    description: 'Filter by admin user ID who performed the action',
  })
  @ApiQuery({
    name: 'related_entity_type',
    required: false,
    description: 'Filter by related entity type (property, deal, commission, user, etc.)',
  })
  @ApiQuery({
    name: 'start_date',
    required: false,
    description: 'Start date for date range filter (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'end_date',
    required: false,
    description: 'End date for date range filter (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'page',
    type: Number,
    required: false,
    description: 'Page number (1-indexed, default 1)',
  })
  @ApiQuery({
    name: 'limit',
    type: Number,
    required: false,
    description: 'Records per page (1-100, default 20)',
  })
  @ApiOkResponse({
    description: 'Activity logs retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        data: { type: 'array' },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
        totalPages: { type: 'number' },
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not an admin' })
  async getActivityLogs(
    @Query() filters: ActivityLogFilterDto,
    @Request() req: any,
  ): Promise<IActivityLogResponse> {
    return await this.adminService.getActivityLogs(filters);
  }

  /**
   * Get activity summary (daily or weekly aggregation)
   *
   * Returns aggregated statistics of admin activities grouped by action type.
   * Useful for dashboards and reporting.
   *
   * Summary Types:
   * - daily: Aggregated by day (default)
   * - weekly: Aggregated by week
   *
   * @param filters - Filter parameters
   * @param req - Express request with authenticated user
   * @returns Activity summary with aggregated counts
   * @throws 401 Unauthorized if token is invalid
   * @throws 403 Forbidden if user is not an admin
   */
  @Get('activity-logs/summary')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Get activity summary',
    description:
      'Returns aggregated statistics of admin activities grouped by action type. Supports daily and weekly aggregation.',
  })
  @ApiQuery({
    name: 'period',
    required: false,
    enum: ['daily', 'weekly'],
    description: 'Summary period (daily or weekly, default daily)',
  })
  @ApiQuery({
    name: 'start_date',
    required: false,
    description: 'Start date for summary period (ISO 8601 format)',
  })
  @ApiQuery({
    name: 'end_date',
    required: false,
    description: 'End date for summary period (ISO 8601 format)',
  })
  @ApiOkResponse({
    description: 'Activity summary retrieved successfully',
    schema: {
      type: 'object',
      properties: {
        period: { type: 'string', enum: ['daily', 'weekly'] },
        start_date: { type: 'string', format: 'date-time' },
        end_date: { type: 'string', format: 'date-time' },
        summary: { type: 'array' },
        total_actions: { type: 'number' },
      },
    },
  })
  @ApiUnauthorizedResponse({ description: 'Unauthorized - Invalid or expired JWT token' })
  @ApiForbiddenResponse({ description: 'Forbidden - User is not an admin' })
  async getActivitySummary(
    @Query() filters: ActivityLogFilterDto,
    @Request() req: any,
  ): Promise<IActivitySummaryResponse> {
    return await this.adminService.getActivitySummary(filters);
  }
}
