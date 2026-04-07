/**
 * Notifications DTOs (Data Transfer Objects)
 * 
 * Handles request/response serialization and validation
 */

import { IsString, IsEnum, IsArray, IsOptional, IsObject, IsBoolean, IsEmail, IsPhoneNumber, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { NotificationType, NotificationChannel, NotificationStatus, NotificationPriority } from './notifications.interface';

/**
 * Create Notification DTO
 * Used for sending notifications
 */
export class CreateNotificationDto {
  @ApiProperty({
    example: 'user-123',
    description: 'User ID to send notification to'
  })
  @IsString()
  userId: string;

  @ApiProperty({
    enum: NotificationType,
    example: NotificationType.PROPERTY_VERIFIED,
    description: 'Type of notification'
  })
  @IsEnum(NotificationType)
  type: NotificationType;

  @ApiProperty({
    isArray: true,
    enum: NotificationChannel,
    example: [NotificationChannel.SMS, NotificationChannel.EMAIL],
    description: 'Channels to send through'
  })
  @IsArray()
  @IsEnum(NotificationChannel, { each: true })
  channels: NotificationChannel[];

  @ApiProperty({
    type: 'object',
    example: {
      userName: 'John Doe',
      propertyTitle: 'Luxury Villa',
      commission: '50000'
    },
    description: 'Template variables for message rendering'
  })
  @IsObject()
  templateData: Record<string, any>;

  @ApiPropertyOptional({
    enum: NotificationPriority,
    default: NotificationPriority.MEDIUM,
    description: 'Priority level'
  })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({
    example: 'Property verified manually',
    description: 'Optional notes or comments'
  })
  @IsOptional()
  @IsString()
  notes?: string;
}

/**
 * Get Notifications Query DTO
 * Used for pagination and filtering
 */
export class GetNotificationsDto {
  @ApiPropertyOptional({
    type: Number,
    default: 1,
    minimum: 1,
    description: 'Page number'
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({
    type: Number,
    default: 20,
    minimum: 1,
    maximum: 100,
    description: 'Items per page'
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({
    enum: NotificationType,
    description: 'Filter by notification type'
  })
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @ApiPropertyOptional({
    enum: NotificationStatus,
    description: 'Filter by notification status'
  })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @ApiPropertyOptional({
    type: Boolean,
    description: 'Show only unread notifications'
  })
  @IsOptional()
  @IsBoolean()
  unreadOnly?: boolean;

  @ApiPropertyOptional({
    type: String,
    example: 'DESC',
    description: 'Sort order (ASC or DESC)'
  })
  @IsOptional()
  @IsString()
  sortBy?: 'ASC' | 'DESC' = 'DESC';
}

/**
 * Mark as Read DTO
 */
export class MarkAsReadDto {
  @ApiProperty({
    type: [String],
    example: ['notification-1', 'notification-2'],
    description: 'Array of notification IDs to mark as read'
  })
  @IsArray()
  @IsString({ each: true })
  notificationIds: string[];
}

/**
 * Notification Preferences DTO
 */
export class NotificationPreferencesDto {
  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Enable email notifications'
  })
  @IsOptional()
  @IsBoolean()
  emailNotifications?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Enable SMS notifications'
  })
  @IsOptional()
  @IsBoolean()
  smsNotifications?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Enable WhatsApp notifications'
  })
  @IsOptional()
  @IsBoolean()
  whatsappNotifications?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Enable in-app notifications'
  })
  @IsOptional()
  @IsBoolean()
  inAppNotifications?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Receive notifications for property verified'
  })
  @IsOptional()
  @IsBoolean()
  propertyVerifiedEnabled?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Receive notifications for new deals'
  })
  @IsOptional()
  @IsBoolean()
  dealCreatedEnabled?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Receive notifications for closed deals'
  })
  @IsOptional()
  @IsBoolean()
  dealClosedEnabled?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Receive notifications for commission credited'
  })
  @IsOptional()
  @IsBoolean()
  commissionCreditedEnabled?: boolean;

  @ApiPropertyOptional({
    type: Boolean,
    default: true,
    description: 'Receive notifications for agent accepted'
  })
  @IsOptional()
  @IsBoolean()
  agentAcceptedEnabled?: boolean;

  @ApiPropertyOptional({
    enum: ['immediately', 'daily', 'weekly', 'never'],
    default: 'immediately',
    description: 'Email notification frequency'
  })
  @IsOptional()
  @IsString()
  emailFrequency?: 'immediately' | 'daily' | 'weekly' | 'never';

  @ApiPropertyOptional({
    enum: ['immediately', 'daily', 'weekly', 'never'],
    default: 'immediately',
    description: 'SMS notification frequency'
  })
  @IsOptional()
  @IsString()
  smsFrequency?: 'immediately' | 'daily' | 'weekly' | 'never';

  @ApiPropertyOptional({
    type: String,
    example: '22:00',
    description: 'Quiet hours start time (HH:mm)'
  })
  @IsOptional()
  @IsString()
  quietHoursStart?: string;

  @ApiPropertyOptional({
    type: String,
    example: '08:00',
    description: 'Quiet hours end time (HH:mm)'
  })
  @IsOptional()
  @IsString()
  quietHoursEnd?: string;
}

/**
 * Notification Response DTO
 */
export class NotificationResponseDto {
  @ApiProperty({
    example: 'notification-123',
    description: 'Unique notification ID'
  })
  id: string;

  @ApiProperty({
    example: 'user-123',
    description: 'User ID'
  })
  userId: string;

  @ApiProperty({
    enum: NotificationType,
    description: 'Notification type'
  })
  type: NotificationType;

  @ApiProperty({
    enum: NotificationChannel,
    description: 'Delivery channel'
  })
  channel: NotificationChannel;

  @ApiProperty({
    enum: NotificationStatus,
    description: 'Current status'
  })
  status: NotificationStatus;

  @ApiProperty({
    example: 'Property Verified',
    description: 'Notification title'
  })
  title: string;

  @ApiProperty({
    example: 'Your property has been verified',
    description: 'Notification message'
  })
  message: string;

  @ApiProperty({
    type: Object,
    description: 'Additional metadata',
    required: false
  })
  metadata?: Record<string, any>;

  @ApiProperty({
    example: 1,
    description: 'Number of delivery attempts'
  })
  deliveryAttempts: number;

  @ApiProperty({
    type: Date,
    description: 'When the notification was read'
  })
  readAt?: Date;

  @ApiProperty({
    type: Date,
    description: 'When the notification was sent'
  })
  sentAt?: Date;

  @ApiProperty({
    type: Date,
    description: 'Creation timestamp'
  })
  createdAt: Date;

  @ApiProperty({
    type: Date,
    description: 'Last update timestamp'
  })
  updatedAt: Date;
}

/**
 * Notification Summary Response DTO
 */
export class NotificationSummaryDto {
  @ApiProperty({
    example: 5,
    description: 'Total unread notifications'
  })
  totalUnread: number;

  @ApiProperty({
    type: Object,
    example: {
      property_verified: 2,
      deal_created: 3
    },
    description: 'Unread count by type'
  })
  byType: Record<NotificationType, number>;

  @ApiProperty({
    type: Object,
    example: {
      sms: 3,
      email: 2,
      in_app: 0
    },
    description: 'Unread count by channel'
  })
  byChannel: Record<NotificationChannel, number>;
}

/**
 * Paginated Notifications Response DTO
 */
export class PaginatedNotificationsDto {
  @ApiProperty({
    type: [NotificationResponseDto],
    description: 'Array of notifications'
  })
  data: NotificationResponseDto[];

  @ApiProperty({
    example: 150,
    description: 'Total count of notifications'
  })
  total: number;

  @ApiProperty({
    example: 1,
    description: 'Current page number'
  })
  page: number;

  @ApiProperty({
    example: 20,
    description: 'Items per page'
  })
  limit: number;

  @ApiProperty({
    example: 8,
    description: 'Total number of pages'
  })
  pages: number;
}

/**
 * Update Preferences Response DTO
 */
export class UpdatePreferencesResponseDto {
  @ApiProperty({
    type: Boolean,
    description: 'Success flag'
  })
  success: boolean;

  @ApiProperty({
    type: String,
    example: 'Preferences updated successfully',
    description: 'Success message'
  })
  message: string;

  @ApiProperty({
    type: NotificationPreferencesDto,
    description: 'Updated preferences'
  })
  preferences: NotificationPreferencesDto;
}

/**
 * Generic Response DTO
 */
export class ResponseDto {
  @ApiProperty({
    type: Boolean,
    description: 'Success flag'
  })
  success: boolean;

  @ApiProperty({
    type: String,
    description: 'Response message'
  })
  message: string;

  @ApiPropertyOptional({
    type: Object,
    description: 'Additional data'
  })
  data?: any;
}
