import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

/**
 * Admin User Entity
 *
 * Represents admin users with special privileges and audit capabilities.
 * Contains admin-specific fields for role management, suspension tracking, and audit trail.
 *
 * Admin roles:
 * - super_admin: Full system access, can manage all admins
 * - property_verifier: Can verify properties
 * - deal_manager: Can manage deals
 * - commission_manager: Can manage commissions
 * - support_agent: Limited support access
 *
 * Features:
 * 1. Admin role-based access control
 * 2. Suspension tracking with reason and timestamp
 * 3. Audit trail of who created/updated admin accounts
 * 4. Activity logging for all admin actions
 *
 * Database:
 * - Table: admin_users
 * - Primary Key: id (auto-generated)
 * - Foreign Key: user_id references users.id
 * - Indexes: user_id, admin_role, is_suspended, created_by_user_id
 *
 * @see AdminActivityLog for activity audit trail
 */
@Entity('admin_users')
@Index(['user_id'])
@Index(['admin_role'])
@Index(['is_suspended'])
@Index(['created_by_user_id'])
export class AdminUser {
  /**
   * Unique admin identifier
   * Auto-generated primary key
   */
  @PrimaryGeneratedColumn()
  id: number;

  /**
   * Foreign key to User entity
   * Links admin user to base user profile
   */
  @ManyToOne(() => User, { nullable: false, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ nullable: false })
  user_id: number;

  /**
   * Admin role - Determines permissions
   *
   * Roles:
   * - super_admin: Full system administrative access
   * - property_verifier: Can verify properties only
   * - deal_manager: Can manage deals and commissions
   * - commission_manager: Can manage commissions
   * - support_agent: Limited support purposes
   */
  @Column({
    type: 'enum',
    enum: ['super_admin', 'property_verifier', 'deal_manager', 'commission_manager', 'support_agent'],
    default: 'support_agent',
  })
  admin_role: 'super_admin' | 'property_verifier' | 'deal_manager' | 'commission_manager' | 'support_agent';

  /**
   * Active status flag
   * true = admin account is active
   * false = admin account is deactivated
   */
  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  /**
   * Suspended status flag
   * true = admin account is suspended
   * false = admin account is not suspended
   * When suspended, admin cannot perform actions
   */
  @Column({ type: 'boolean', default: false })
  is_suspended: boolean;

  /**
   * Reason for suspension
   * Only populated when is_suspended is true
   */
  @Column({ type: 'varchar', length: 500, nullable: true })
  suspended_reason: string;

  /**
   * Timestamp when admin was suspended
   */
  @Column({ type: 'timestamp', nullable: true })
  suspended_at: Date;

  /**
   * Admin ID of the user who suspended this admin
   * For audit trail
   */
  @Column({ type: 'int', nullable: true })
  suspended_by_user_id: number;

  /**
   * Admin ID of the user who created this admin account
   * For audit trail
   */
  @Column({ type: 'int', nullable: false })
  created_by_user_id: number;

  /**
   * When this admin account was created
   */
  @CreateDateColumn()
  created_at: Date;

  /**
   * When this admin account was last updated
   */
  @UpdateDateColumn()
  updated_at: Date;
}
