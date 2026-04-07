import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { AdminUser } from '../../database/entities/admin-user.entity';
import { AdminActivityLog } from '../../database/entities/admin-activity-log.entity';
import { User } from '../../database/entities/user.entity';

/**
 * Admin Module - Complete Admin Management System
 *
 * Comprehensive module for managing admin users and audit logging.
 *
 * Features:
 * - Admin user CRUD operations (Create, Read, Update)
 * - Role-based access control (5 different roles)
 * - Admin account suspension and reactivation
 * - Comprehensive activity audit logging
 * - Flexible activity log filtering with pagination
 * - Daily/weekly activity summary reports
 * - Security tracking (IP addresses, timestamps)
 *
 * Admin Roles:
 * - super_admin: Full system access, can manage all admins
 * - property_verifier: Can verify properties
 * - deal_manager: Can manage deals and their lifecycle
 * - commission_manager: Can manage commissions and payments
 * - support_agent: Limited support agent access
 *
 * Endpoints (with /v1/admin prefix):
 * - GET /users - List all admin users
 * - POST /users - Create new admin (requires super_admin)
 * - GET /users/:id - Get admin details
 * - PUT /users/:id - Update admin details
 * - POST /users/:id/suspend - Suspend admin account (requires super_admin)
 * - POST /users/:id/unsuspend - Reactivate admin account (requires super_admin)
 * - GET /activity-logs - Get paginated activity logs
 * - GET /activity-logs/summary - Get activity summary (daily/weekly)
 *
 * Activity Logging:
 * - All admin actions are automatically logged
 * - Tracks: action type, timestamp, IP address, related entity
 * - Supports flexible filtering by action type, entity type, date range, admin ID
 * - Pagination support (1-100 records per page)
 *
 * Database:
 * - Entity: AdminUser (in database/entities/admin-user.entity.ts)
 * - Entity: AdminActivityLog (in database/entities/admin-activity-log.entity.ts)
 * - Tables: admin_users, admin_activity_logs
 * - Foreign Keys: admin_users.user_id -> users.id
 *
 * Business Rules:
 * 1. Only super_admin can create, suspend, or unsuspend other admins
 * 2. Email must be globally unique across all admins
 * 3. Admin accounts cannot be deleted, only suspended
 * 4. All admin actions are logged for compliance and security
 * 5. Admin role changes require super_admin authorization
 * 6. Suspended admins cannot authenticate or perform actions
 *
 * Security Requirements:
 * - All endpoints protected by JWT authentication (JwtAuthGuard)
 * - Most endpoints require admin role (AdminGuard)
 * - Create/suspend operations require super_admin role
 * - IP addresses tracked for all admin actions
 * - Full audit trail maintained for compliance
 *
 * Dependencies:
 * - TypeORM for database abstraction
 * - JWT authentication (from Auth module)
 * - Admin and JWT guards (from common guards)
 * - Dependency injection throughout
 *
 * Integration Points:
 * - Used by other modules (Properties, Deals, Commissions) for activity logging
 * - Integrates with Auth module for JWT validation
 * - Uses User entity for admin profile information
 * - Provides services for activity logging to other modules
 *
 * Exports:
 * - AdminService: For activity logging by other modules
 * - AdminController: REST API endpoints
 *
 * Usage by other modules:
 * ```typescript
 * @Module({
 *   imports: [AdminModule],
 *   // Then inject AdminService where needed
 * })
 * export class PropertiesModule { ... }
 *
 * // In a service:
 * constructor(private adminService: AdminService) {}
 *
 * // Log an activity:
 * await this.adminService.logActivity(
 *   adminUserId,
 *   'property_verified',
 *   'property',
 *   propertyId,
 *   { verification_type: 'ownership' },
 *   ipAddress
 * );
 * ```
 *
 * Ready for Phase 1 production
 */
@Module({
  imports: [TypeOrmModule.forFeature([AdminUser, AdminActivityLog, User])],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService], // Export for use by other modules (activity logging)
})
export class AdminModule {}
