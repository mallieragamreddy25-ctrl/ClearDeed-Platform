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
import { Deal } from './deal.entity';
import { Property } from './property.entity';

/**
 * Notification Entity
 * 
 * Tracks all notifications sent to users
 * Supports multiple channels: SMS, WhatsApp, Push
 * Tracks delivery status and retry attempts
 */
@Entity('notifications')
@Index(['user_id'])
@Index(['delivery_status'])
@Index(['created_at'])
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column()
  user_id: number;

  @Column({ type: 'varchar', length: 100, nullable: true })
  notification_type: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  title: string;

  @Column({ type: 'text', nullable: true })
  body: string;

  @Column({ type: 'varchar', length: 50, default: 'sms' })
  channel: 'sms' | 'whatsapp' | 'push';

  @Column({ type: 'varchar', length: 20, nullable: true })
  recipient_mobile: string;

  @Column({ type: 'varchar', nullable: true })
  recipient_email: string;

  @Column({ type: 'timestamp', nullable: true })
  sent_at: Date;

  @Column({ type: 'varchar', length: 50, default: 'pending' })
  delivery_status: 'pending' | 'sent' | 'failed';

  @Column({ type: 'int', default: 0 })
  delivery_attempts: number;

  @Column({ type: 'timestamp', nullable: true })
  last_attempt_at: Date;

  @ManyToOne(() => Deal, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'related_deal_id' })
  related_deal: Deal;

  @Column({ nullable: true })
  related_deal_id: number;

  @ManyToOne(() => Property, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'related_property_id' })
  related_property: Property;

  @Column({ nullable: true })
  related_property_id: number;

  @CreateDateColumn()
  created_at: Date;
}
