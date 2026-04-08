/**
 * Notifications Service
 * 
 * Core business logic for:
 * - Sending notifications across channels
 * - Template rendering
 * - Queue management
 * - Retry logic
 */

import { Injectable, Logger, BadRequestException, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Notification,
  NotificationPreferences,
  NotificationAuditLog,
  NotificationQueueJob,
} from './notification.entity';
import {
  NotificationType,
  NotificationChannel,
  NotificationStatus,
  NotificationPriority,
  ISendNotificationRequest,
  INotificationSummary,
  INotificationsPaginatedResponse,
  INotification,
} from './notifications.interface';
import {
  getTemplate,
  replaceVariables,
  SMS_TEMPLATES,
  EMAIL_TEMPLATES,
  WHATSAPP_TEMPLATES,
  IN_APP_TEMPLATES,
} from './notification-templates';
import { TwilioService } from './twilio.service';
import { CreateNotificationDto, GetNotificationsDto, NotificationPreferencesDto } from './notifications.dto';

/**
 * Notifications Service
 * 
 * Handles all notification operations including sending, storing, and managing preferences
 */
@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  // Simple in-memory queue for demo (use Bull/BullMQ in production)
  private notificationQueue: Map<string, NotificationQueueJob> = new Map();

  constructor(
    @InjectRepository(Notification)
    private notificationsRepository: Repository<Notification>,
    @InjectRepository(NotificationPreferences)
    private preferencesRepository: Repository<NotificationPreferences>,
    @InjectRepository(NotificationAuditLog)
    private auditLogRepository: Repository<NotificationAuditLog>,
    @InjectRepository(NotificationQueueJob)
    private queueJobRepository: Repository<NotificationQueueJob>,
    private twilioService: TwilioService,
  ) {
    this.initializeQueue();
  }

  /**
   * Initialize the notification queue processor
   */
  private initializeQueue(): void {
    // Process queue every 5 seconds
    setInterval(async () => {
      await this.processQueue();
    }, 5000);

    this.logger.log('Notification queue processor initialized');
  }

  /**
   * Process pending queue jobs
   */
  private async processQueue(): Promise<void> {
    try {
      const pendingJobs = await this.queueJobRepository.find({
        where: { status: 'pending' },
        order: { priority: 'ASC', createdAt: 'ASC' },
        take: 10, // Process 10 at a time
      });

      for (const job of pendingJobs) {
        await this.processQueueJob(job);
      }
    } catch (error) {
      this.logger.error('Error processing queue', error);
    }
  }

  /**
   * Process a single queue job
   */
  private async processQueueJob(job: NotificationQueueJob): Promise<void> {
    try {
      job.status = 'processing';
      job.processedAt = new Date();
      await this.queueJobRepository.save(job);

      const channels = job.channels.map((ch) => ch as NotificationChannel);
      await this.sendNotification({
        userId: job.userId,
        type: job.type,
        channels,
        templateData: job.data,
        priority: job.priority,
      });

      job.status = 'completed';
      await this.queueJobRepository.save(job);
    } catch (error) {
      job.retryCount++;

      if (job.retryCount >= job.maxRetries) {
        job.status = 'failed';
        job.failureReason = error.message;
        this.logger.error(`Queue job ${job.id} failed after max retries`, error);
      }

      await this.queueJobRepository.save(job);
    }
  }

  /**
   * Send notification across one or more channels
   * 
   * @param request - Notification request with user, type, channels, and template data
   */
  async sendNotification(request: ISendNotificationRequest): Promise<INotification[]> {
    this.logger.log(`Sending ${request.type} notification to user ${request.userId}`);

    // Check user preferences
    const preferences = await this.getOrCreatePreferences(request.userId);

    // Get template and validate availability
    const allNotifications: INotification[] = [];

    for (const channel of request.channels) {
      // Check if channel is enabled in preferences
      if (!this.isChannelEnabled(channel, preferences)) {
        this.logger.log(`Channel ${channel} disabled for user ${request.userId}`);
        continue;
      }

      // Check if notification type is enabled
      if (!this.isNotificationTypeEnabled(request.type, preferences)) {
        this.logger.log(`Notification type ${request.type} disabled for user ${request.userId}`);
        continue;
      }

      // Get template for this channel
      const template = getTemplate(request.type, channel);
      if (!template) {
        this.logger.warn(`No template found for ${request.type} on ${channel}`);
        continue;
      }

      // Create notification record
      const notification = await this.createNotification(
        request.userId,
        request.type,
        channel,
        template,
        request.templateData,
        request.priority || NotificationPriority.MEDIUM,
      );

      // @ts-ignore - DTO type compatibility
      allNotifications.push(notification);

      // Send based on channel
      await this.sendByChannel(notification, template, request.templateData);
    }

    return allNotifications;
  }

  /**
   * Create a new notification record in database
   */
  private async createNotification(
    userId: string,
    type: NotificationType,
    channel: NotificationChannel,
    template: any,
    templateData: Record<string, any>,
    priority: NotificationPriority = NotificationPriority.MEDIUM,
  ): Promise<INotification> {
    const message = replaceVariables(template.body, templateData);
    const title = replaceVariables(template.title, templateData);

    const notification = this.notificationsRepository.create({
      id: randomUUID(),
      userId,
      type,
      channel,
      status: NotificationStatus.PENDING,
      title,
      message,
      body: message,
      metadata: templateData,
      deliveryAttempts: 0,
      maxRetries: 3,
      priority,
    });

    const saved = await this.notificationsRepository.save(notification);

    this.logger.log(`Notification created: ${saved.id} for user ${userId} on channel ${channel}`);

    return saved;
  }

  /**
   * Send notification by channel
   */
  private async sendByChannel(
    notification: Notification,
    template: any,
    templateData: Record<string, any>,
  ): Promise<void> {
    const message = replaceVariables(template.body, templateData);
    const phone = templateData.phone || templateData.userPhone;
    const email = templateData.email || templateData.userEmail;

    switch (notification.channel) {
      case NotificationChannel.SMS:
        await this.sendViaMultipleAttempts(
          notification,
          () => this.twilioService.sendSms(phone, message),
        );
        break;

      case NotificationChannel.WHATSAPP:
        await this.sendViaMultipleAttempts(
          notification,
          () => this.twilioService.sendWhatsApp(phone, message),
        );
        break;

      case NotificationChannel.EMAIL:
        // Email sending would be implemented with service like SendGrid, AWS SES, etc.
        await this.sendEmailNotification(notification, template, templateData);
        break;

      case NotificationChannel.IN_APP:
        // In-app notification is stored in DB (already done)
        notification.status = NotificationStatus.SENT;
        notification.sentAt = new Date();
        notification.deliveryAttempts = 1;
        await this.notificationsRepository.save(notification);
        await this.logAuditTrail(notification, 'sent', NotificationStatus.SENT);
        break;

      default:
        this.logger.warn(`Unknown channel: ${notification.channel}`);
    }
  }

  /**
   * Send with retry logic (max 3 times)
   */
  private async sendViaMultipleAttempts(
    notification: Notification,
    sendFn: () => Promise<any>,
  ): Promise<void> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt < notification.maxRetries; attempt++) {
      try {
        notification.deliveryAttempts = attempt + 1;
        notification.lastAttemptAt = new Date();

        const result = await sendFn();

        if (result.success) {
          notification.status = NotificationStatus.SENT;
          notification.sentAt = new Date();
          notification.externalId = result.sid;
          await this.notificationsRepository.save(notification);
          await this.logAuditTrail(
            notification,
            'sent',
            NotificationStatus.SENT,
            `Sent on attempt ${attempt + 1}`,
          );
          return;
        } else {
          lastError = new Error(result.error || 'Unknown error');
        }
      } catch (error) {
        lastError = error;
      }

      // Wait before retrying (exponential backoff: 1s, 2s, 4s)
      if (attempt < notification.maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    // Mark as failed if all retries exhausted
    notification.status = NotificationStatus.FAILED;
    await this.notificationsRepository.save(notification);
    await this.logAuditTrail(
      notification,
      'failed',
      NotificationStatus.FAILED,
      lastError?.message || 'Max retries exceeded',
    );

    this.logger.error(
      `Failed to send notification ${notification.id} after ${notification.maxRetries} attempts`,
      lastError,
    );
  }

  /**
   * Send email notification
   * 
   * Currently mocked - integrate with SendGrid, AWS SES, or similar
   */
  private async sendEmailNotification(
    notification: Notification,
    template: any,
    templateData: Record<string, any>,
  ): Promise<void> {
    try {
      const email = templateData.email || templateData.userEmail;
      const subject = template.subject || template.title;
      const body = replaceVariables(template.body, templateData);

      // Mock email sending - replace with actual provider
      this.logger.log(`[EMAIL] To: ${email}, Subject: ${subject}, Body: ${body.substring(0, 100)}...`);

      notification.status = NotificationStatus.SENT;
      notification.sentAt = new Date();
      notification.deliveryAttempts++;
      notification.externalId = `EMAIL_${Date.now()}`;

      await this.notificationsRepository.save(notification);
      await this.logAuditTrail(notification, 'sent', NotificationStatus.SENT);
    } catch (error) {
      this.logger.error(`Failed to send email: ${error.message}`, error);
      notification.status = NotificationStatus.FAILED;
      await this.notificationsRepository.save(notification);
      await this.logAuditTrail(notification, 'failed', NotificationStatus.FAILED, error.message);
    }
  }

  /**
   * Get notifications for a user
   */
  async getNotifications(
    userId: string,
    query: GetNotificationsDto,
  ): Promise<INotificationsPaginatedResponse> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    let qb = this.notificationsRepository.createQueryBuilder('n').where('n.userId = :userId', { userId });

    if (query.type) {
      qb = qb.andWhere('n.type = :type', { type: query.type });
    }

    if (query.status) {
      qb = qb.andWhere('n.status = :status', { status: query.status });
    }

    if (query.unreadOnly) {
      qb = qb.andWhere('n.readAt IS NULL');
    }

    qb = qb.orderBy('n.createdAt', query.sortBy === 'ASC' ? 'ASC' : 'DESC').skip(skip).take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    };
  }

  /**
   * Mark notification (or multiple) as read
   */
  async markAsRead(userId: string, notificationIds: string[]): Promise<number> {
    const now = new Date();

    const result = await this.notificationsRepository
      .createQueryBuilder()
      .update(Notification)
      .set({ readAt: now, status: NotificationStatus.READ })
      .where('id IN (:...ids)', { ids: notificationIds })
      .andWhere('userId = :userId', { userId })
      .execute();

    // Log audit trail
    for (const id of notificationIds) {
      const notification = await this.notificationsRepository.findOne({ where: { id } });
      if (notification) {
        await this.logAuditTrail(notification, 'read', NotificationStatus.READ);
      }
    }

    return result.affected || 0;
  }

  /**
   * Get notification summary (unread count, etc.)
   */
  async getNotificationSummary(userId: string): Promise<INotificationSummary> {
    const { IsNull } = require('typeorm');
    const unread = await this.notificationsRepository.find({
      where: { userId, readAt: IsNull() },
    });

    const byType: Record<NotificationType, number> = {} as any;
    const byChannel: Record<NotificationChannel, number> = {} as any;

    unread.forEach((n) => {
      byType[n.type] = (byType[n.type] || 0) + 1;
      byChannel[n.channel] = (byChannel[n.channel] || 0) + 1;
    });

    return {
      totalUnread: unread.length,
      byType,
      byChannel,
    };
  }

  /**
   * Get or create notification preferences
   */
  async getOrCreatePreferences(userId: string): Promise<NotificationPreferences> {
    let preferences = await this.preferencesRepository.findOne({ where: { userId } });

    if (!preferences) {
      preferences = this.preferencesRepository.create({
        id: randomUUID(),
        userId,
        emailNotifications: true,
        smsNotifications: true,
        whatsappNotifications: true,
        inAppNotifications: true,
        propertyVerifiedEnabled: true,
        dealCreatedEnabled: true,
        dealClosedEnabled: true,
        commissionCreditedEnabled: true,
        agentAcceptedEnabled: true,
        emailFrequency: 'immediately',
        smsFrequency: 'immediately',
      });

      preferences = await this.preferencesRepository.save(preferences);
      this.logger.log(`Created default preferences for user ${userId}`);
    }

    return preferences;
  }

  /**
   * Update notification preferences
   */
  async updatePreferences(
    userId: string,
    updateDto: NotificationPreferencesDto,
  ): Promise<NotificationPreferences> {
    let preferences = await this.getOrCreatePreferences(userId);

    Object.assign(preferences, updateDto);

    preferences = await this.preferencesRepository.save(preferences);
    this.logger.log(`Updated preferences for user ${userId}`);

    return preferences;
  }

  /**
   * Check if channel is enabled in user preferences
   */
  private isChannelEnabled(channel: NotificationChannel, preferences: NotificationPreferences): boolean {
    switch (channel) {
      case NotificationChannel.EMAIL:
        return preferences.emailNotifications;
      case NotificationChannel.SMS:
        return preferences.smsNotifications;
      case NotificationChannel.WHATSAPP:
        return preferences.whatsappNotifications;
      case NotificationChannel.IN_APP:
        return preferences.inAppNotifications;
      default:
        return false;
    }
  }

  /**
   * Check if notification type is enabled
   */
  private isNotificationTypeEnabled(
    type: NotificationType,
    preferences: NotificationPreferences,
  ): boolean {
    switch (type) {
      case NotificationType.PROPERTY_VERIFIED:
        return preferences.propertyVerifiedEnabled;
      case NotificationType.DEAL_CREATED:
        return preferences.dealCreatedEnabled;
      case NotificationType.DEAL_CLOSED:
        return preferences.dealClosedEnabled;
      case NotificationType.COMMISSION_CREDITED:
        return preferences.commissionCreditedEnabled;
      case NotificationType.AGENT_ACCEPTED:
        return preferences.agentAcceptedEnabled;
      default:
        return true;
    }
  }

  /**
   * Log audit trail for notification action
   */
  private async logAuditTrail(
    notification: Notification,
    action: 'sent' | 'failed' | 'read' | 'bounced' | 'retried',
    status: NotificationStatus,
    reason?: string,
  ): Promise<void> {
    const log = this.auditLogRepository.create({
      id: randomUUID(),
      notificationId: notification.id,
      userId: notification.userId,
      action,
      status,
      reason,
      attempt: notification.deliveryAttempts,
      externalServiceId: notification.externalId,
    });

    await this.auditLogRepository.save(log);
  }

  /**
   * Queue a notification for async processing
   */
  async queueNotification(request: ISendNotificationRequest): Promise<NotificationQueueJob> {
    const job = this.queueJobRepository.create({
      id: randomUUID(),
      userId: request.userId,
      type: request.type,
      channels: request.channels,
      data: request.templateData,
      retryCount: 0,
      maxRetries: 3,
      priority: request.priority || NotificationPriority.MEDIUM,
      status: 'pending',
    });

    const saved = await this.queueJobRepository.save(job);
    this.logger.log(`Queued notification job: ${saved.id}`);

    return saved;
  }

  /**
   * Get audit logs for a notification
   */
  async getAuditLogs(notificationId: string): Promise<NotificationAuditLog[]> {
    return this.auditLogRepository.find({
      where: { notificationId },
      order: { createdAt: 'DESC' },
    });
  }
}
