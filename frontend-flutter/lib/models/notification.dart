import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// Notification model
@JsonSerializable()
class AppNotification {
  final String id;
  final String userId;
  final String type; // sms, whatsapp, push, email, in_app
  final String title;
  final String message;
  final String? actionUrl;
  final String? actionLabel;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String priority; // low, normal, high

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.actionLabel,
    this.metadata,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.priority = 'normal',
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  bool get isSms => type == 'sms';
  bool get isWhatsApp => type == 'whatsapp';
  bool get isPush => type == 'push';
  bool get isEmail => type == 'email';
  bool get isInApp => type == 'in_app';
  bool get isHighPriority => priority == 'high';
  bool get isOldNotification {
    final age = DateTime.now().difference(createdAt);
    return age.inDays > 30;
  }
}

/// Notification preferences
@JsonSerializable()
class NotificationPreferences {
  final String id;
  final String userId;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool smsNotificationsEnabled;
  final bool whatsappNotificationsEnabled;
  final List<String> enabledCategories; // property_updates, deals, investments, etc.
  final bool quietHoursEnabled;
  final String? quietStartTime; // HH:MM format
  final String? quietEndTime; // HH:MM format
  final bool unsubscribedAll;

  NotificationPreferences({
    required this.id,
    required this.userId,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.smsNotificationsEnabled,
    required this.whatsappNotificationsEnabled,
    required this.enabledCategories,
    required this.quietHoursEnabled,
    this.quietStartTime,
    this.quietEndTime,
    required this.unsubscribedAll,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencestoJson(this);
}
