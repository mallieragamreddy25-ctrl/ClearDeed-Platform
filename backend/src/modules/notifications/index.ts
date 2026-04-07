/**
 * Notifications Module - Public Exports
 * 
 * Exposes all public interfaces, DTOs, entities, and services
 */

// Module
export { NotificationsModule } from './notifications.module';

// Controllers
export { NotificationsController } from './notifications.controller';

// Services
export { NotificationsService } from './notifications.service';
export { TwilioService } from './twilio.service';

// Entities
export {
  Notification,
  NotificationPreferences,
  NotificationAuditLog,
  NotificationQueueJob,
} from './notification.entity';

// Interfaces
export {
  NotificationType,
  NotificationChannel,
  NotificationStatus,
  NotificationPriority,
  INotification,
  INotificationPreferences,
  INotificationTemplate,
  INotificationJob,
  ITwilioResponse,
  IEmailResponse,
  ISendNotificationRequest,
  INotificationSummary,
  INotificationsPaginatedResponse,
  INotificationAuditLog,
  INotificationStats,
} from './notifications.interface';

// DTOs
export {
  CreateNotificationDto,
  GetNotificationsDto,
  MarkAsReadDto,
  NotificationPreferencesDto,
  NotificationResponseDto,
  NotificationSummaryDto,
  PaginatedNotificationsDto,
  UpdatePreferencesResponseDto,
  ResponseDto,
} from './notifications.dto';

// Templates
export {
  SMS_TEMPLATES,
  EMAIL_TEMPLATES,
  WHATSAPP_TEMPLATES,
  IN_APP_TEMPLATES,
  getTemplate,
  replaceVariables,
} from './notification-templates';
