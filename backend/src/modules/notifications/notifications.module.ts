/**
 * Notifications Module
 * 
 * NestJS module definition for the notifications system
 * Exports services for use by other modules
 */

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';

import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { TwilioService } from './twilio.service';
import {
  Notification,
  NotificationPreferences,
  NotificationAuditLog,
  NotificationQueueJob,
} from './notification.entity';

/**
 * Notifications Module
 * 
 * Provides:
 * - Notification sending across multiple channels (SMS, Email, WhatsApp, In-App)
 * - User preference management
 * - Queue-based async processing
 * - Retry logic with exponential backoff
 * - Audit trail logging
 * - Twilio integration
 * 
 * Exports:
 * - NotificationsService (for use by other modules)
 */
@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([
      Notification,
      NotificationPreferences,
      NotificationAuditLog,
      NotificationQueueJob,
    ]),
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, TwilioService],
  exports: [NotificationsService, TwilioService], // Export for use by other modules
})
export class NotificationsModule {}
