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
import { ReferralPartner } from './referral-partner.entity';

/**
 * AgentMaintenance Entity
 * 
 * Tracks maintenance fee payments for referral partners
 * Annual fee requirement for agents to remain active
 * Renewal tracking and payment history
 */
@Entity('agent_maintenance')
@Index(['referral_partner_id'])
@Index(['is_active'])
export class AgentMaintenance {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => ReferralPartner, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referral_partner_id' })
  referral_partner: ReferralPartner;

  @Column()
  referral_partner_id: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 999 })
  fee_amount: number;

  @Column({ type: 'timestamp', nullable: true })
  payment_date: Date;

  @Column({ type: 'varchar', length: 255, nullable: true })
  payment_reference: string;

  @Column({ type: 'date', nullable: true })
  fee_expiry_date: Date;

  @Column({ type: 'boolean', default: false })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
