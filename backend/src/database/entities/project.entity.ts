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
 * Project Entity
 * 
 * Represents investment projects
 * Can be real estate development projects, mutual funds, etc.
 * Similar lifecycle to Property with verification
 */
@Entity('projects')
@Index(['admin_user_id'])
@Index(['status'])
@Index(['city'])
export class Project {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'admin_user_id' })
  admin_user: User;

  @Column({ nullable: true })
  admin_user_id: number;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  location: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string;

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  capital_required: number;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  minimum_investment: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  roi_estimate: number;

  @Column({ type: 'int', nullable: true })
  timeline_months: number;

  @Column({
    type: 'enum',
    enum: ['submitted', 'under_verification', 'verified', 'live', 'sold', 'rejected'],
    default: 'submitted',
  })
  status: 'submitted' | 'under_verification' | 'verified' | 'live' | 'sold' | 'rejected';

  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  @Column({ type: 'boolean', default: false })
  verified_badge: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  verified_at: Date;
}
