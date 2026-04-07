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
import { Property } from './property.entity';
import { Project } from './project.entity';

/**
 * Deal Entity
 * 
 * Represents a transaction between buyer and seller
 * Can be for either a property or a project
 * Tracks deal progression from creation to closure
 * 
 * Statuses:
 * - open: Deal created, awaiting closure
 * - closed: Deal finalized, commissions calculated
 * 
 * Payment Statuses:
 * - pending: Awaiting payment
 * - completed: Payment received
 * 
 * Commission Tracking:
 * - Commission percentages locked at deal creation
 * - Final commissions calculated on deal closure
 */
@Entity('deals')
@Index(['buyer_user_id'])
@Index(['seller_user_id'])
@Index(['property_id'])
@Index(['status'])
@Index(['payment_status'])
export class Deal {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'created_by_admin_id' })
  created_by_admin: User;

  @Column({ nullable: true })
  created_by_admin_id: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'buyer_user_id' })
  buyer_user: User;

  @Column()
  buyer_user_id: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'seller_user_id' })
  seller_user: User;

  @Column()
  seller_user_id: number;

  @ManyToOne(() => Property, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  @Column({ nullable: true })
  property_id: number;

  @ManyToOne(() => Project, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'project_id' })
  project: Project;

  @Column({ nullable: true })
  project_id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'referral_partner_id' })
  referral_partner: User;

  @Column({ nullable: true })
  referral_partner_id: number;

  @Column({ type: 'decimal', precision: 15, scale: 2, nullable: true })
  transaction_value: number;

  @Column({
    type: 'enum',
    enum: ['open', 'closed'],
    default: 'open',
  })
  status: 'open' | 'closed';

  @Column({
    type: 'enum',
    enum: ['pending', 'completed'],
    default: 'pending',
  })
  payment_status: 'pending' | 'completed';

  @Column({ type: 'timestamp', nullable: true })
  payment_date: Date;

  @Column({ type: 'timestamp', nullable: true })
  commission_locked_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  deal_closed_at: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
