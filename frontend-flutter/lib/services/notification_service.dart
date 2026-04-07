import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Push notification service
class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Request permissions on iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    required String payload,
    String? imageUrl,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cleardeed_channel',
      'ClearDeed Notifications',
      channelDescription: 'Notifications for ClearDeed',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      title.hashCode,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Show progress notification
  Future<void> showProgressNotification({
    required String title,
    required int progress,
    required String payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cleardeed_progress',
      'Progress Notifications',
      channelDescription: 'Progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: 100,
      indeterminate: false,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Note: iOS doesn't support progress notifications this way
    await flutterLocalNotificationsPlugin.show(
      'progress'.hashCode,
      title,
      '$progress%',
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) =>
      flutterLocalNotificationsPlugin.cancel(id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications() =>
      flutterLocalNotificationsPlugin.cancelAll();

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      flutterLocalNotificationsPlugin.pendingNotificationRequests();
}
