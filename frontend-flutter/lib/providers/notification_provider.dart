import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/api_client.dart';
import '../utils/app_logger.dart';
import 'package:dio/dio.dart';

// ==================== Notification List State ====================

class NotificationListState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int unreadCount;
  final int page;

  const NotificationListState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.unreadCount = 0,
    this.page = 1,
  });

  NotificationListState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? unreadCount,
    int? page,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
      page: page ?? this.page,
    );
  }
}

/// Exception for notification related errors
class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  NotificationException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Notification service for handling notification API calls
class NotificationService {
  final ApiClient _apiClient;

  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get list of notifications
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    String? type,
    bool? unreadOnly = false,
  }) async {
    try {
      AppLogger.logFunctionEntry('getNotifications', {
        'page': page,
        'type': type,
        'unreadOnly': unreadOnly,
      });

      final queryParams = {
        'page': page,
        'limit': 20,
        if (type != null) 'type': type,
        if (unreadOnly == true) 'unread_only': true,
      };

      final response = await _apiClient.get(
        '/v1/notifications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<AppNotification> notifications = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          notifications = data
              .map((item) => AppNotification.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList();
        } else if (data is Map && data['notifications'] != null) {
          notifications = List<Map<String, dynamic>>.from(data['notifications'])
              .map((item) => AppNotification.fromJson(item))
              .toList();
        }

        AppLogger.logFunctionExit('getNotifications', 'Got ${notifications.length} notifications');
        return notifications;
      } else {
        throw NotificationException(
          message: 'Failed to fetch notifications',
          code: 'GET_NOTIFICATIONS_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get notifications failed: ${e.message}', e);
      throw NotificationException(
        message: _handleDioError(e),
        code: 'GET_NOTIFICATIONS_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get notifications error: $e', e);
      if (e is NotificationException) rethrow;
      throw NotificationException(
        message: 'An unexpected error occurred',
        code: 'GET_NOTIFICATIONS_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      AppLogger.logFunctionEntry('markAsRead', {'notificationId': notificationId});

      final response = await _apiClient.patch(
        '/v1/notifications/$notificationId/mark-read',
      );

      if (response.statusCode == 200) {
        AppLogger.logFunctionExit('markAsRead', 'Marked as read');
        return true;
      } else {
        throw NotificationException(
          message: 'Failed to mark notification as read',
          code: 'MARK_READ_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Mark as read failed: ${e.message}', e);
      throw NotificationException(
        message: _handleDioError(e),
        code: 'MARK_READ_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Mark as read error: $e', e);
      if (e is NotificationException) rethrow;
      throw NotificationException(
        message: 'An unexpected error occurred',
        code: 'MARK_READ_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      AppLogger.logFunctionEntry('markAllAsRead');

      final response = await _apiClient.patch(
        '/v1/notifications/mark-all-read',
      );

      if (response.statusCode == 200) {
        AppLogger.logFunctionExit('markAllAsRead', 'All marked as read');
        return true;
      } else {
        throw NotificationException(
          message: 'Failed to mark all notifications as read',
          code: 'MARK_ALL_READ_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Mark all as read failed: ${e.message}', e);
      throw NotificationException(
        message: _handleDioError(e),
        code: 'MARK_ALL_READ_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Mark all as read error: $e', e);
      if (e is NotificationException) rethrow;
      throw NotificationException(
        message: 'An unexpected error occurred',
        code: 'MARK_ALL_READ_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      AppLogger.logFunctionEntry('deleteNotification', {'notificationId': notificationId});

      final response = await _apiClient.delete(
        '/v1/notifications/$notificationId',
      );

      if (response.statusCode == 200) {
        AppLogger.logFunctionExit('deleteNotification', 'Deleted');
        return true;
      } else {
        throw NotificationException(
          message: 'Failed to delete notification',
          code: 'DELETE_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Delete notification failed: ${e.message}', e);
      throw NotificationException(
        message: _handleDioError(e),
        code: 'DELETE_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Delete notification error: $e', e);
      if (e is NotificationException) rethrow;
      throw NotificationException(
        message: 'An unexpected error occurred',
        code: 'DELETE_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get notification count (unread)
  Future<int> getUnreadCount() async {
    try {
      AppLogger.logFunctionEntry('getUnreadCount');

      final response = await _apiClient.get(
        '/v1/notifications/unread-count',
      );

      if (response.statusCode == 200) {
        final count = response.data['count'] ?? 0;
        AppLogger.logFunctionExit('getUnreadCount', 'Unread count: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      AppLogger.error('Get unread count error: $e', e);
      return 0;
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data['message'] ?? 'API Error';

      if (statusCode == 400) {
        return 'Invalid request: $message';
      } else if (statusCode == 401) {
        return 'Unauthorized - Please login again';
      } else if (statusCode == 404) {
        return 'Notification not found';
      } else if (statusCode == 500) {
        return 'Server error - Please try again later';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout - Please check your network';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Network error - Please check your internet connection';
    }

    return 'An error occurred - Please try again';
  }
}

// ==================== Providers ====================

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient: apiClient);
});

/// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Notification type filter provider
final notificationTypeFilterProvider =
    StateProvider<String?>((ref) => null);

/// Notifications list state
class NotificationListState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int unreadCount;
  final String? typeFilter;

  const NotificationListState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.unreadCount = 0,
    this.typeFilter,
  });

  NotificationListState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? unreadCount,
    String? typeFilter,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}

/// Notifications list provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationListState>(
        (ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final typeFilter = ref.watch(notificationTypeFilterProvider);
  return NotificationsNotifier(notificationService, typeFilter);
});

/// Notifications list state notifier
class NotificationsNotifier extends StateNotifier<NotificationListState> {
  final NotificationService _notificationService;
  final String? _typeFilter;
  int _currentPage = 1;

  NotificationsNotifier(this._notificationService, this._typeFilter)
      : super(const NotificationListState()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.logFunctionEntry('_loadNotifications', {
        'page': _currentPage,
        'type': _typeFilter,
      });

      final notifications = await _notificationService.getNotifications(
        page: _currentPage,
        type: _typeFilter,
      );

      final unreadCount = await _notificationService.getUnreadCount();

      final isFirstPage = _currentPage == 1;
      final newNotifications =
          isFirstPage ? notifications : [...state.notifications, ...notifications];

      state = state.copyWith(
        notifications: newNotifications,
        isLoading: false,
        hasMore: notifications.length >= 20,
        unreadCount: unreadCount,
        typeFilter: _typeFilter,
      );

      AppLogger.logFunctionExit('_loadNotifications',
          'Loaded ${notifications.length} notifications, unread: $unreadCount');
    } catch (e) {
      AppLogger.error('Load notifications error: $e', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshNotifications() async {
    _currentPage = 1;
    await _loadNotifications();
  }

  Future<void> loadMoreNotifications() async {
    if (!state.hasMore || state.isLoading) return;
    _currentPage++;
    await _loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      AppLogger.logFunctionEntry('markAsRead', {'notificationId': notificationId});

      await _notificationService.markAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notif) {
        if (notif.id == notificationId) {
          return AppNotification(
            id: notif.id,
            userId: notif.userId,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            actionUrl: notif.actionUrl,
            actionLabel: notif.actionLabel,
            metadata: notif.metadata,
            isRead: true,
            createdAt: notif.createdAt,
            readAt: DateTime.now(),
            imageUrl: notif.imageUrl,
            priority: notif.priority,
          );
        }
        return notif;
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: (state.unreadCount - 1).clamp(0, double.infinity).toInt(),
      );

      AppLogger.logFunctionExit('markAsRead', 'Marked successfully');
    } catch (e) {
      AppLogger.error('Mark as read error: $e', e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      AppLogger.logFunctionEntry('markAllAsRead');

      await _notificationService.markAllAsRead();

      // Update local state
      final updatedNotifications = state.notifications
          .map((notif) => AppNotification(
            id: notif.id,
            userId: notif.userId,
            type: notif.type,
            title: notif.title,
            message: notif.message,
            actionUrl: notif.actionUrl,
            actionLabel: notif.actionLabel,
            metadata: notif.metadata,
            isRead: true,
            createdAt: notif.createdAt,
            readAt: DateTime.now(),
            imageUrl: notif.imageUrl,
            priority: notif.priority,
          ))
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      AppLogger.logFunctionExit('markAllAsRead', 'All marked');
    } catch (e) {
      AppLogger.error('Mark all as read error: $e', e);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      AppLogger.logFunctionEntry('deleteNotification', {'notificationId': notificationId});

      await _notificationService.deleteNotification(notificationId);

      // Update local state
      final updatedNotifications = state.notifications
          .where((notif) => notif.id != notificationId)
          .toList();

      state = state.copyWith(
        notifications: updatedNotifications,
      );

      AppLogger.logFunctionExit('deleteNotification', 'Deleted');
    } catch (e) {
      AppLogger.error('Delete notification error: $e', e);
    }
  }
}

/// Unread notification count provider
final unreadNotificationCountProvider =
    FutureProvider<int>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.getUnreadCount();
});
