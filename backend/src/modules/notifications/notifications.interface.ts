/**
 * Notifications Module - TypeScript Interfaces
 * 
 * Defines all interfaces for the notifications system:
 * - Notification types
 * - Channels
 * - Preferences
 * - Templates
 * - Queue jobs
 */

/**
 * Notification types supported by the system
 */
export enum NotificationType {
  PROPERTY_VERIFIED = 'property_verified',
  DEAL_CREATED = 'deal_created',
  DEAL_CLOSED = 'deal_closed',
  COMMISSION_CREDITED = 'commission_credited',
  AGENT_ACCEPTED = 'agent_accepted',
  PROPERTY_REJECTED = 'property_rejected',
  DEAL_UPDATED = 'deal_updated',
}

/**
 * Notification channels
 */
export enum NotificationChannel {
  SMS = 'sms',
  EMAIL = 'email',
  IN_APP = 'in_app',
  WHATSAPP = 'whatsapp',
}

/**
 * Notification status
 */
export enum NotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed',
  READ = 'read',
  BOUNCED = 'bounced',
}

/**
 * Notification Priority
 */
export enum NotificationPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
}

/**
 * Core Notification Interface
 */
export interface INotification {
  id: string;
  userId: string;
  type: NotificationType;
  channel: NotificationChannel;
  status: NotificationStatus;
  priority: NotificationPriority;
  title: string;
  message: string;
  body?: string;
  metadata?: Record<string, any>;
  deliveryAttempts: number;
  maxRetries: number;
  lastAttemptAt?: Date;
  sentAt?: Date;
  readAt?: Date;
  createdAt: Date;
  updatedAt: Date;
  externalId?: string; // Twilio SID, Email ID, etc.
}

/**
 * User Notification Preferences
 */
export interface INotificationPreferences {
  userId: string;
  emailNotifications: boolean;
  smsNotifications: boolean;
  whatsappNotifications: boolean;
  inAppNotifications: boolean;
  
  // Type-specific preferences
  propertyVerifiedEnabled: boolean;
  dealCreatedEnabled: boolean;
  dealClosedEnabled: boolean;
  commissionCreditedEnabled: boolean;
  agentAcceptedEnabled: boolean;
  
  // Frequency preferences
  emailFrequency: 'immediately' | 'daily' | 'weekly' | 'never';
  smsFrequency: 'immediately' | 'daily' | 'weekly' | 'never';
  
  // Quiet hours
  quietHoursStart?: string; // HH:mm format
  quietHoursEnd?: string; // HH:mm format
  
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Notification Template Interface
 */
export interface INotificationTemplate {
  type: NotificationType;
  channel: NotificationChannel;
  subject?: string; // For email
  title: string;
  body: string;
  variables: string[]; // Variables like {{agentName}}, {{propertyId}}
}

/**
 * Queue Job for sending notifications
 */
export interface INotificationJob {
  id: string;
  userId: string;
  type: NotificationType;
  channels: NotificationChannel[];
  data: Record<string, any>;
  retryCount: number;
  maxRetries: number;
  priority: NotificationPriority;
  createdAt: Date;
  processedAt?: Date;
}

/**
 * Twilio Service Response
 */
export interface ITwilioResponse {
  success: boolean;
  sid?: string; // Twilio Message SID
  status: string;
  error?: string;
}

/**
 * Email Service Response
 */
export interface IEmailResponse {
  success: boolean;
  messageId?: string;
  status: string;
  error?: string;
}

/**
 * Send Notification Request
 */
export interface ISendNotificationRequest {
  userId: string;
  type: NotificationType;
  channels: NotificationChannel[];
  templateData: Record<string, any>;
  priority?: NotificationPriority;
}

/**
 * Notification Summary (Statistics)
 */
export interface INotificationSummary {
  totalUnread: number;
  byType: Record<NotificationType, number>;
  byChannel: Record<NotificationChannel, number>;
}

/**
 * Paginated Notifications Response
 */
export interface INotificationsPaginatedResponse {
  data: INotification[];
  total: number;
  page: number;
  limit: number;
  pages: number;
}

/**
 * Audit Trail for Notifications
 */
export interface INotificationAuditLog {
  id: string;
  notificationId: string;
  userId: string;
  action: 'sent' | 'failed' | 'read' | 'bounced' | 'retried';
  status: NotificationStatus;
  reason?: string;
  attempt?: number;
  externalServiceId?: string; // Twilio SID, etc.
  createdAt: Date;
}

/**
 * Statistics for Admin Dashboard
 */
export interface INotificationStats {
  totalSent: number;
  totalFailed: number;
  successRate: number;
  averageDeliveryTime: number; // in seconds
  byType: Record<NotificationType, number>;
  byChannel: Record<NotificationChannel, number>;
  period: {
    start: Date;
    end: Date;
  };
}
