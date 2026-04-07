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
 * ReferralPartner Entity
 * 
 * Represents agents or verified users who can refer deals
 * Tracks commission earnings and maintenance fees
 * 
 * Types:
 * - agent: Licensed real estate agent
 * - verified_user: Regular user verified for referrals
 */
@Entity('referral_partners')
@Index(['mobile_number'])
@Index(['user_id'])
@Index(['status'])
export class ReferralPartner {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ nullable: true })
  user_id: number;

  @Column({ type: 'varchar', length: 20, unique: true })
  mobile_number: string;

  @Column({
    type: 'enum',
    enum: ['agent', 'verified_user'],
  })
  partner_type: 'agent' | 'verified_user';

  @Column({ type: 'varchar', length: 255, nullable: true })
  full_name: string;

  @Column({ type: 'varchar', nullable: true })
  email: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  city: string;

  // Agent specific
  @Column({ type: 'varchar', length: 100, nullable: true })
  agent_license_number: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  agency_name: string;

  // Status
  @Column({
    type: 'enum',
    enum: ['pending', 'under_review', 'approved', 'rejected'],
    default: 'pending',
  })
  status: 'pending' | 'under_review' | 'approved' | 'rejected';

  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  @Column({ type: 'varchar', length: 50, default: 'unpaid' })
  yearly_maintenance_fee_status: string;

  @Column({ type: 'date', nullable: true })
  maintenance_fee_renewal_date: Date;

  @Column({ type: 'boolean', default: false })
  commission_enabled: boolean;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  total_commission_earned: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
