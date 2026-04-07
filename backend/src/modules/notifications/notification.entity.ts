/**
 * Notification Entity
 * 
 * TypeORM entity for storing notification records in the database
 */

import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { NotificationType, NotificationChannel, NotificationStatus, NotificationPriority } from './notifications.interface';

/**
 * Notification Entity
 * 
 * Stores all notification records with status tracking and audit trail
 */
@Entity('notifications')
@Index(['userId', 'createdAt'])
@Index(['userId', 'status'])
@Index(['status', 'createdAt'])
@Index(['type'])
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

  @Column({
    type: 'enum',
    enum: NotificationChannel,
  })
  channel: NotificationChannel;

  @Column({
    type: 'enum',
    enum: NotificationStatus,
    default: NotificationStatus.PENDING,
  })
  status: NotificationStatus;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'text', nullable: true })
  body?: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>;

  @Column({ type: 'int', default: 0 })
  deliveryAttempts: number;

  @Column({ type: 'int', default: 3 })
  maxRetries: number;

  @Column({ type: 'timestamptz', nullable: true })
  lastAttemptAt?: Date;

  @Column({ type: 'timestamptz', nullable: true })
  sentAt?: Date;

  @Column({ type: 'timestamptz', nullable: true })
  readAt?: Date;

  @Column({ type: 'varchar', nullable: true })
  externalId?: string; // Twilio SID, Email ID, etc.

  @Column({
    type: 'enum',
    enum: NotificationPriority,
    default: NotificationPriority.MEDIUM,
  })
  priority: NotificationPriority;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;

  @OneToMany(() => NotificationAuditLog, (log) => log.notification, { cascade: true })
  auditLogs?: NotificationAuditLog[];
}

/**
 * Notification Preferences Entity
 * 
 * Stores user notification preferences and settings
 */
@Entity('notification_preferences')
@Index(['userId'], { unique: true })
export class NotificationPreferences {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid', { unique: true })
  userId: string;

  @Column({ type: 'boolean', default: true })
  emailNotifications: boolean;

  @Column({ type: 'boolean', default: true })
  smsNotifications: boolean;

  @Column({ type: 'boolean', default: true })
  whatsappNotifications: boolean;

  @Column({ type: 'boolean', default: true })
  inAppNotifications: boolean;

  // Type-specific preferences
  @Column({ type: 'boolean', default: true })
  propertyVerifiedEnabled: boolean;

  @Column({ type: 'boolean', default: true })
  dealCreatedEnabled: boolean;

  @Column({ type: 'boolean', default: true })
  dealClosedEnabled: boolean;

  @Column({ type: 'boolean', default: true })
  commissionCreditedEnabled: boolean;

  @Column({ type: 'boolean', default: true })
  agentAcceptedEnabled: boolean;

  // Frequency preferences
  @Column({
    type: 'enum',
    enum: ['immediately', 'daily', 'weekly', 'never'],
    default: 'immediately',
  })
  emailFrequency: 'immediately' | 'daily' | 'weekly' | 'never';

  @Column({
    type: 'enum',
    enum: ['immediately', 'daily', 'weekly', 'never'],
    default: 'immediately',
  })
  smsFrequency: 'immediately' | 'daily' | 'weekly' | 'never';

  // Quiet hours
  @Column({ type: 'time', nullable: true })
  quietHoursStart?: string; // HH:mm format

  @Column({ type: 'time', nullable: true })
  quietHoursEnd?: string; // HH:mm format

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;
}

/**
 * Notification Audit Log Entity
 * 
 * Maintains audit trail for each notification's delivery attempts
 */
@Entity('notification_audit_logs')
@Index(['notificationId'])
@Index(['userId'])
@Index(['createdAt'])
export class NotificationAuditLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  notificationId: string;

  @ManyToOne(() => Notification, (notification) => notification.auditLogs)
  @JoinColumn({ name: 'notificationId' })
  notification?: Notification;

  @Column('uuid')
  userId: string;

  @Column({
    type: 'enum',
    enum: ['sent', 'failed', 'read', 'bounced', 'retried'],
  })
  action: 'sent' | 'failed' | 'read' | 'bounced' | 'retried';

  @Column({
    type: 'enum',
    enum: NotificationStatus,
  })
  status: NotificationStatus;

  @Column({ type: 'text', nullable: true })
  reason?: string;

  @Column({ type: 'int', nullable: true })
  attempt?: number;

  @Column({ type: 'varchar', nullable: true })
  externalServiceId?: string; // Twilio SID, SendGrid ID, etc.

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;
}

/**
 * Notification Queue Job Entity
 * 
 * Stores pending notification jobs for async processing
 */
@Entity('notification_queue_jobs')
@Index(['status'])
@Index(['priority'])
@Index(['createdAt'])
export class NotificationQueueJob {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  userId: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
  })
  type: NotificationType;

  @Column({
    type: 'simple-array',
  })
  channels: string[]; // Array of NotificationChannel

  @Column({ type: 'jsonb' })
  data: Record<string, any>;

  @Column({ type: 'int', default: 0 })
  retryCount: number;

  @Column({ type: 'int', default: 3 })
  maxRetries: number;

  @Column({
    type: 'enum',
    enum: NotificationPriority,
    default: NotificationPriority.MEDIUM,
  })
  priority: NotificationPriority;

  @Column({
    type: 'enum',
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending',
  })
  status: 'pending' | 'processing' | 'completed' | 'failed';

  @Column({ type: 'text', nullable: true })
  failureReason?: string;

  @CreateDateColumn({ type: 'timestamptz' })
  createdAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  processedAt?: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updatedAt: Date;
}
