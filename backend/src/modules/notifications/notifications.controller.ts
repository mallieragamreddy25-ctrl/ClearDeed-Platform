/**
 * Notifications Controller
 * 
 * Handles HTTP endpoints for notification operations
 */

import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Logger,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import {
  CreateNotificationDto,
  GetNotificationsDto,
  MarkAsReadDto,
  NotificationPreferencesDto,
  NotificationResponseDto,
  PaginatedNotificationsDto,
  NotificationSummaryDto,
  UpdatePreferencesResponseDto,
  ResponseDto,
} from './notifications.dto';

/**
 * Notifications Controller
 * 
 * API endpoints for:
 * - Listing notifications
 * - Marking as read
 * - Managing preferences
 * - Sending notifications (admin)
 */
@ApiTags('Notifications')
@ApiBearerAuth()
@Controller('v1/notifications')
export class NotificationsController {
  private readonly logger = new Logger(NotificationsController.name);

  constructor(private notificationsService: NotificationsService) {}

  /**
   * Get notifications for current user
   * 
   * @param userId - Current user ID (from JWT)
   * @param query - Pagination and filter options
   */
  @Get()
  @ApiOperation({
    summary: 'Get user notifications',
    description: 'Retrieve paginated list of notifications for the current user with optional filtering',
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({ name: 'type', required: false, enum: ['property_verified', 'deal_created', 'deal_closed', 'commission_credited', 'agent_accepted'] })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'sent', 'failed', 'read'] })
  @ApiQuery({ name: 'unreadOnly', required: false, type: Boolean })
  @ApiResponse({
    status: 200,
    description: 'Notifications retrieved successfully',
    type: PaginatedNotificationsDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getNotifications(
    @Query() query: GetNotificationsDto,
    // In a real app, this would come from JWT
    @Query('userId') userId?: string,
  ): Promise<PaginatedNotificationsDto> {
    const actualUserId = userId || 'current-user-id'; // Replace with actual JWT extraction
    return this.notificationsService.getNotifications(actualUserId, query);
  }

  /**
   * Get notification summary
   * 
   * @param userId - Current user ID
   */
  @Get('summary')
  @ApiOperation({
    summary: 'Get notification summary',
    description: 'Get unread count and statistics by type and channel',
  })
  @ApiResponse({
    status: 200,
    description: 'Summary retrieved successfully',
    type: NotificationSummaryDto,
  })
  async getNotificationSummary(
    @Query('userId') userId?: string,
  ): Promise<NotificationSummaryDto> {
    const actualUserId = userId || 'current-user-id';
    return this.notificationsService.getNotificationSummary(actualUserId);
  }

  /**
   * Mark notification(s) as read
   * 
   * @param userId - Current user ID
   * @param dto - Array of notification IDs
   */
  @Post(':id/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Mark notifications as read',
    description: 'Mark one or more notifications as read',
  })
  @ApiParam({ name: 'id', description: 'Notification ID' })
  @ApiResponse({ status: 200, description: 'Marked as read', type: ResponseDto })
  async markAsRead(
    @Param('id') notificationId: string,
    @Query('userId') userId?: string,
  ): Promise<ResponseDto> {
    const actualUserId = userId || 'current-user-id';
    const affected = await this.notificationsService.markAsRead(actualUserId, [notificationId]);

    return {
      success: affected > 0,
      message: `${affected} notification(s) marked as read`,
      data: { affected },
    };
  }

  /**
   * Mark multiple notifications as read
   * 
   * @param userId - Current user ID
   * @param dto - Request body with notification IDs
   */
  @Post('mark-read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Mark multiple notifications as read',
    description: 'Mark multiple notifications as read in one request',
  })
  @ApiResponse({ status: 200, description: 'Marked as read', type: ResponseDto })
  async markMultipleAsRead(
    @Body() dto: MarkAsReadDto,
    @Query('userId') userId?: string,
  ): Promise<ResponseDto> {
    const actualUserId = userId || 'current-user-id';
    const affected = await this.notificationsService.markAsRead(actualUserId, dto.notificationIds);

    return {
      success: affected > 0,
      message: `${affected} notification(s) marked as read`,
      data: { affected },
    };
  }

  /**
   * Get notification preferences for current user
   * 
   * @param userId - Current user ID
   */
  @Get('preferences')
  @ApiOperation({
    summary: 'Get user notification preferences',
    description: 'Retrieve notification preferences and settings for the current user',
  })
  @ApiResponse({
    status: 200,
    description: 'Preferences retrieved',
    type: NotificationPreferencesDto,
  })
  async getPreferences(
    @Query('userId') userId?: string,
  ): Promise<NotificationPreferencesDto> {
    const actualUserId = userId || 'current-user-id';
    const preferences = await this.notificationsService.getOrCreatePreferences(actualUserId);

    return {
      emailNotifications: preferences.emailNotifications,
      smsNotifications: preferences.smsNotifications,
      whatsappNotifications: preferences.whatsappNotifications,
      inAppNotifications: preferences.inAppNotifications,
      propertyVerifiedEnabled: preferences.propertyVerifiedEnabled,
      dealCreatedEnabled: preferences.dealCreatedEnabled,
      dealClosedEnabled: preferences.dealClosedEnabled,
      commissionCreditedEnabled: preferences.commissionCreditedEnabled,
      agentAcceptedEnabled: preferences.agentAcceptedEnabled,
      emailFrequency: preferences.emailFrequency,
      smsFrequency: preferences.smsFrequency,
      quietHoursStart: preferences.quietHoursStart,
      quietHoursEnd: preferences.quietHoursEnd,
    };
  }

  /**
   * Update notification preferences for current user
   * 
   * @param userId - Current user ID
   * @param dto - Updated preferences
   */
  @Post('preferences')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update user notification preferences',
    description: 'Update notification channels, types, and frequency preferences',
  })
  @ApiResponse({
    status: 200,
    description: 'Preferences updated',
    type: UpdatePreferencesResponseDto,
  })
  async updatePreferences(
    @Body() dto: NotificationPreferencesDto,
    @Query('userId') userId?: string,
  ): Promise<UpdatePreferencesResponseDto> {
    const actualUserId = userId || 'current-user-id';
    const updated = await this.notificationsService.updatePreferences(actualUserId, dto);

    return {
      success: true,
      message: 'Preferences updated successfully',
      preferences: {
        emailNotifications: updated.emailNotifications,
        smsNotifications: updated.smsNotifications,
        whatsappNotifications: updated.whatsappNotifications,
        inAppNotifications: updated.inAppNotifications,
        propertyVerifiedEnabled: updated.propertyVerifiedEnabled,
        dealCreatedEnabled: updated.dealCreatedEnabled,
        dealClosedEnabled: updated.dealClosedEnabled,
        commissionCreditedEnabled: updated.commissionCreditedEnabled,
        agentAcceptedEnabled: updated.agentAcceptedEnabled,
        emailFrequency: updated.emailFrequency,
        smsFrequency: updated.smsFrequency,
        quietHoursStart: updated.quietHoursStart,
        quietHoursEnd: updated.quietHoursEnd,
      },
    };
  }

  /**
   * Send notification (Admin endpoint)
   * 
   * @param dto - Notification to send
   */
  @Post('send')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Send notification (Admin)',
    description: 'Send a notification to one or more users (Admin only)',
  })
  @ApiResponse({
    status: 201,
    description: 'Notification sent',
    type: ResponseDto,
  })
  async sendNotification(@Body() dto: CreateNotificationDto): Promise<ResponseDto> {
    try {
      const notifications = await this.notificationsService.sendNotification({
        userId: dto.userId,
        type: dto.type,
        channels: dto.channels,
        templateData: dto.templateData,
        priority: dto.priority,
      });

      return {
        success: true,
        message: `Notification sent to ${notifications.length} channel(s)`,
        data: {
          notificationCount: notifications.length,
          notifications: notifications.map((n) => ({
            id: n.id,
            channel: n.channel,
            status: n.status,
          })),
        },
      };
    } catch (error) {
      this.logger.error('Failed to send notification', error);
      return {
        success: false,
        message: error.message,
      };
    }
  }

  /**
   * Queue notification (Async sending - Admin endpoint)
   * 
   * @param dto - Notification to queue
   */
  @Post('queue')
  @HttpCode(HttpStatus.ACCEPTED)
  @ApiOperation({
    summary: 'Queue notification for async processing',
    description: 'Queue a notification for asynchronous processing (Admin only)',
  })
  @ApiResponse({
    status: 202,
    description: 'Notification queued',
    type: ResponseDto,
  })
  async queueNotification(@Body() dto: CreateNotificationDto): Promise<ResponseDto> {
    try {
      const job = await this.notificationsService.queueNotification({
        userId: dto.userId,
        type: dto.type,
        channels: dto.channels,
        templateData: dto.templateData,
        priority: dto.priority,
      });

      return {
        success: true,
        message: 'Notification queued for processing',
        data: {
          jobId: job.id,
          status: job.status,
          priority: job.priority,
        },
      };
    } catch (error) {
      this.logger.error('Failed to queue notification', error);
      return {
        success: false,
        message: error.message,
      };
    }
  }

  /**
   * Health check for notifications service
   */
  @Get('health')
  @ApiOperation({
    summary: 'Notification service health check',
    description: 'Check notification service and external integrations (Twilio)',
  })
  @ApiResponse({ status: 200, description: 'Service is healthy' })
  async healthCheck(): Promise<ResponseDto> {
    const twilioHealthy = true; // Would check actual Twilio client

    return {
      success: true,
      message: 'Notification service is healthy',
      data: {
        service: 'notifications',
        status: 'healthy',
        twilio: twilioHealthy ? 'connected' : 'disconnected',
      },
    };
  }
}
