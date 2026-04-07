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
import { Deal } from './deal.entity';
import { ReferralPartner } from './referral-partner.entity';

/**
 * CommissionLedger Entity
 * 
 * Tracks all commission payments
 * Can be:
 * - buyer_fee: Fee from buyer side
 * - seller_fee: Fee from seller side
 * - platform_fee: ClearDeed platform fee
 * - referral_fee: Referral partner commission
 */
@Entity('commission_ledgers')
@Index(['deal_id'])
@Index(['referral_partner_id'])
@Index(['status'])
export class CommissionLedger {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Deal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'deal_id' })
  deal: Deal;

  @Column()
  deal_id: number;

  @ManyToOne(() => ReferralPartner, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'referral_partner_id' })
  referral_partner: ReferralPartner;

  @Column({ nullable: true })
  referral_partner_id: number;

  @Column({
    type: 'enum',
    enum: ['buyer_fee', 'seller_fee', 'platform_fee', 'referral_fee'],
  })
  commission_type: 'buyer_fee' | 'seller_fee' | 'platform_fee' | 'referral_fee';

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  amount: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  percentage_applied: number;

  @Column({ type: 'varchar', length: 50, default: 'pending' })
  status: 'pending' | 'approved' | 'paid';

  @Column({ type: 'timestamp', nullable: true })
  payment_date: Date;

  @Column({ type: 'varchar', length: 255, nullable: true })
  payment_reference: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}
