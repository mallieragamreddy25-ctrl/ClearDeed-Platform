import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

/**
 * AdminActivityLog Entity
 * 
 * Audit trail for all admin actions
 * Tracks property verifications, deal creation, referral approvals, etc.
 * Includes metadata and IP address for security
 */
@Entity('admin_activity_logs')
@Index(['admin_user_id'])
@Index(['created_at'])
export class AdminActivityLog {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'admin_user_id' })
  admin_user: User;

  @Column({ nullable: true })
  admin_user_id: number;

  @Column({ type: 'varchar', length: 100 })
  action_type: string;

  @Column({ type: 'varchar', length: 100 })
  related_entity_type: string;

  @Column({ type: 'int', nullable: true })
  related_entity_id: number;

  @Column({ type: 'jsonb', nullable: true })
  action_details: Record<string, any>;

  @Column({ type: 'varchar', length: 45, nullable: true })
  ip_address: string;

  @CreateDateColumn()
  created_at: Date;
}
