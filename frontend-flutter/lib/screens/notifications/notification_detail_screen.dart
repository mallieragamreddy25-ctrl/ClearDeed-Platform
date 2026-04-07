import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_logger.dart';

/// Notification detail screen - displays full notification content
class NotificationDetailScreen extends ConsumerWidget {
  final AppNotification notification;

  const NotificationDetailScreen({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Details'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptions(context, ref);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and status
            _NotificationHeader(notification: notification),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    notification.title,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),

                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDetailedTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (notification.readAt != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Read ${_formatDetailedTime(notification.readAt!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: AppTheme.lightGrey, height: 1),
                  const SizedBox(height: 24),

                  // Message content
                  Text(
                    'Message',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.textHint.withOpacity(0.3)),
                    ),
                    child: Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),

                  // Metadata section
                  if (notification.metadata != null && notification.metadata!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Additional Details',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildMetadataItems(context, notification.metadata!),
                  ],

                  // Image if available
                  if (notification.imageUrl != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Attached Image',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        notification.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppTheme.lightGrey,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppTheme.textHint,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action button
                  if (notification.actionUrl != null) ...[
                    Divider(color: AppTheme.lightGrey, height: 1),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          AppLogger.logNavigation(
                            'NotificationDetail',
                            'ActionButton_${notification.id}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening: ${notification.actionLabel ?? 'Link'}'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(notification.actionLabel ?? 'Open'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mark as read/unread
            ListTile(
              leading: Icon(
                notification.isRead ? Icons.drafts : Icons.mark_email_unread,
                color: AppTheme.primaryBlue,
              ),
              title: Text(
                notification.isRead ? 'Mark as Unread' : 'Mark as Read',
              ),
              onTap: () {
                if (!notification.isRead) {
                  ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      notification.isRead
                          ? 'Marked as unread'
                          : 'Marked as read',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            // Delete
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.errorRed),
              title: const Text('Delete Notification'),
              onTap: () {
                ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetadataItems(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    return metadata.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '${entry.key}:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                entry.value.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatDetailedTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

// ==================== Notification Header Widget ====================

class _NotificationHeader extends StatelessWidget {
  final AppNotification notification;

  const _NotificationHeader({required this.notification});

  String? _getTypeLabel() {
    switch (notification.type) {
      case 'sms':
        return 'SMS';
      case 'whatsapp':
        return 'WhatsApp';
      case 'email':
        return 'Email';
      case 'push':
        return 'Push Notification';
      case 'in_app':
        return 'In-App';
      default:
        return null;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'sms':
        return Icons.sms;
      case 'whatsapp':
        return Icons.whatsapp;
      case 'email':
        return Icons.email;
      case 'push':
        return Icons.notifications;
      case 'in_app':
        return Icons.info;
      default:
        return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isHighPriority
            ? AppTheme.errorRed.withOpacity(0.1)
            : AppTheme.primaryBlue.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textHint.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getTypeIcon(),
            size: 32,
            color: notification.isHighPriority ? AppTheme.errorRed : AppTheme.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_getTypeLabel() != null)
                  Text(
                    _getTypeLabel() ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 2),
                if (!notification.isRead)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.infoBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'UNREAD',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (notification.isHighPriority)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'URGENT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
