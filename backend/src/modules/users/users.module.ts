import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { UserRepository } from './user.repository';
import { User } from '../../database/entities/user.entity';

/**
 * Users Module - Core User Management
 *
 * Comprehensive module for managing user profiles, profile completion, and referral validation.
 *
 * Features:
 * - OTP-based phone authentication (handled by Auth module)
 * - Profile creation and completion workflow
 * - Profile updates with email uniqueness validation
 * - Referral system with validation
 * - User role/mode selection (buyer, seller, investor)
 * - Referral mobile validation for partners/agents
 *
 * Endpoints (with /v1/users prefix):
 * - GET /profile - Get current authenticated user profile
 * - POST /profile - Create/complete user profile after OTP verification
 * - PUT /profile - Update user profile (supports partial updates)
 * - POST /mode-select - Switch between buyer/seller/investor roles
 * - GET /referral-validation/:mobile - Validate referral mobile number
 *
 * Database:
 * - Entity: User (in database/entities/user.entity.ts)
 * - Table: users
 * - Key Fields: id, mobile_number, email, full_name, profile_type, is_verified, is_active
 * - Indexes: mobile_number, email, referral_mobile_number, is_active
 * - Timestamps: created_at (auto), updated_at (auto)
 *
 * Dependencies:
 * - TypeORM for database abstraction
 * - User entity with proper relationships
 * - JWT authentication guard
 * - Dependency injection throughout
 *
 * Exports:
 * - UsersService: For use by other modules (Auth, Properties, etc.)
 * - UserRepository: Custom repository methods for advanced queries
 *
 * Usage by other modules:
 * ```typescript
 * @Module({
 *   imports: [UsersModule],
 *   // Then inject UsersService where needed
 * })
 * ```
 */
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService, UserRepository],
  exports: [UsersService, UserRepository],
})
export class UsersModule {}
