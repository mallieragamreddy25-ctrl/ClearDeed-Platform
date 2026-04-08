import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Deal } from './deal.entity';
import { ReferralPartner } from './referral-partner.entity';

/**
 * DealReferralMapping Entity
 * 
 * Links referral partners to deals
 * Tracks which partner referred buyer or seller
 * Stores commission percentage for this specific deal
 */
@Entity('deal_referral_mappings')
@Index(['deal_id'])
@Index(['referral_partner_id'])
export class DealReferralMapping {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => Deal, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'deal_id' })
  deal: Deal;

  @Column()
  deal_id: number;

  @ManyToOne(() => ReferralPartner, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referral_partner_id' })
  referral_partner: ReferralPartner;

  @Column()
  referral_partner_id: number;

  @Column({ type: 'varchar', length: 10 })
  side: 'buyer' | 'seller';

  @Column({ type: 'decimal', precision: 5, scale: 2 })
  commission_percentage: number;

  @Column({ type: 'varchar', length: 120, nullable: true, unique: true })
  tracking_token: string;

  @Column({ type: 'timestamp', nullable: true })
  commission_locked_at: Date;

  @CreateDateColumn()
  created_at: Date;
}
