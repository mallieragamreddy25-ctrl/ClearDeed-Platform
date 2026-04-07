import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/notification.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_logger.dart';
import 'notification_detail_screen.dart';

/// Notifications Screen - Displays all notifications with type filtering
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late ScrollController _scrollController;
  String _selectedFilter = 'all'; // all, verification, deal, commission

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      final notifier = ref.read(notificationsProvider.notifier);
      notifier.loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),

          // Notifications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: notificationsAsync.when(
                data: (notifications) {
                  final filtered = _filterNotifications(notifications);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        context,
                        filtered[index],
                      );
                    },
                  );
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      ('all', 'All'),
      ('verification', 'Verification'),
      ('deal', 'Deals'),
      ('commission', 'Commission'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.borderGrey,
                  ),
                ),
                child: Text(
                  filter.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? AppTheme.white : AppTheme.primaryBlue.withOpacity(0.05),
      child: InkWell(
        onTap: () => _openNotificationDetail(context, notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textHint,
                            fontSize: 11,
                          ),
                        ),
                        Row(
                          children: [
                            if (notification.actionUrl != null)
                              GestureDetector(
                                onTap: () => AppLogger.info(
                                  'Action triggered: ${notification.actionUrl}',
                                ),
                                child: Text(
                                  notification.actionLabel ?? 'View',
                                  style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteNotification(notification.id);
                  } else if (value == 'mark_read') {
                    _markAsRead(notification.id);
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.done, size: 18),
                          SizedBox(width: 8),
                          Text('Mark as read'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppTheme.errorRed),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.errorRed),
                        ),
                      ],
                    ),
                  ),
                ],
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Loading notifications...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    AppLogger.error('Notifications Error: $error');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(notificationsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<AppNotification> _filterNotifications(
    List<AppNotification> notifications,
  ) {
    if (_selectedFilter == 'all') {
      return notifications;
    }

    // Map filter names to notification types
    Map<String, List<String>> filterMapping = {
      'verification': ['sms', 'email'],
      'deal': ['in_app', 'push'],
      'commission': ['push', 'email'],
    };

    final typesToFilter = filterMapping[_selectedFilter] ?? [];
    return notifications
        .where((n) => typesToFilter.contains(n.type))
        .toList();
  }

  void _openNotificationDetail(
    BuildContext context,
    AppNotification notification,
  ) {
    _markAsRead(notification.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          notification: notification,
        ),
      ),
    );
  }

  void _markAsRead(String notificationId) {
    // Implementation would call provider to mark as read
    AppLogger.info('Mark as read: $notificationId');
  }

  void _deleteNotification(String notificationId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
      ),
    );
    // Implementation would call provider to delete notification
    AppLogger.info('Delete notification: $notificationId');
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'sms':
      case 'whatsapp':
        return AppTheme.successGreen;
      case 'push':
        return AppTheme.infoBlue;
      case 'email':
        return AppTheme.warningOrange;
      case 'in_app':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.accentGrey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sms':
      case 'whatsapp':
        return Icons.sms;
      case 'push':
        return Icons.notifications;
      case 'email':
        return Icons.mail;
      case 'in_app':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}


class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      final notifier = ref.read(notificationsProvider.notifier);
      notifier.loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount new',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (state) {
          if (state.notifications.isEmpty && !state.isLoading) {
            return _EmptyState(
              onRetry: () {
                ref.invalidate(notificationsProvider);
              },
            );
          }

          // Group notifications by type
          final grouped = _groupNotificationsByType(state.notifications);

          return RefreshIndicator(
            onRefresh: () {
              return ref.read(notificationsProvider.notifier).refresh();
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: grouped.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == grouped.length) {
                  return const _LoadingIndicator();
                }

                final group = grouped[index];
                return _NotificationGroup(
                  type: group['type'] as String,
                  notifications: group['notifications'] as List<AppNotification>,
                  onMarkAsRead: (notification) {
                    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                  },
                  onDelete: (notification) {
                    ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const _LoadingSkeleton(),
        error: (error, stackTrace) => _ErrorState(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(notificationsProvider);
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _groupNotificationsByType(
    List<AppNotification> notifications,
  ) {
    final groups = <String, List<AppNotification>>{};

    for (final notification in notifications) {
      final type = _getNotificationType(notification.type);
      groups.putIfAbsent(type, () => []).add(notification);
    }

    return groups.entries
        .map((entry) => {
          'type': entry.key,
          'notifications': entry.value,
        })
        .toList();
  }

  String _getNotificationType(String type) {
    switch (type) {
      case 'sms':
        return 'SMS';
      case 'whatsapp':
        return 'WhatsApp';
      case 'push':
        return 'Push Notifications';
      case 'email':
        return 'Email';
      case 'in_app':
        return 'In-App';
      default:
        return 'Other';
    }
  }
}

// ==================== Notification Group Widget ====================

class _NotificationGroup extends StatelessWidget {
  final String type;
  final List<AppNotification> notifications;
  final Function(AppNotification) onMarkAsRead;
  final Function(AppNotification) onDelete;

  const _NotificationGroup({
    required this.type,
    required this.notifications,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  IconData _getTypeIcon() {
    switch (type) {
      case 'SMS':
        return Icons.sms;
      case 'WhatsApp':
        return Icons.whatsapp;
      case 'Email':
        return Icons.email;
      case 'Push Notifications':
        return Icons.notifications;
      case 'In-App':
        return Icons.info;
      default:
        return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(_getTypeIcon(), size: 20, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(
                type,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notifications.length.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Group items
        ...notifications.map((notification) => _NotificationItem(
          notification: notification,
          onTap: () {
            AppLogger.logNavigation('Notifications', 'NotificationDetail_${notification.id}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationDetailScreen(notification: notification),
              ),
            );
          },
          onMarkAsRead: () => onMarkAsRead(notification),
          onDelete: () => onDelete(notification),
        )),
      ],
    );
  }
}

// ==================== Notification Item Widget ====================

class _NotificationItem extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        color: widget.notification.isRead ? AppTheme.white : AppTheme.lightGrey,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 12, top: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notification.title,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: widget.notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(widget.notification.createdAt),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    if (widget.notification.isHighPriority)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.1),
                          border: Border.all(color: AppTheme.errorRed),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'URGENT',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Message preview
                Text(
                  widget.notification.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (widget.notification.message.length > 100)
                  const SizedBox(height: 4),
                if (widget.notification.message.length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() => _isExpanded = !_isExpanded);
                    },
                    child: Text(
                      _isExpanded ? 'Show less' : 'Show more',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.notification.actionLabel != null)
                      Flexible(
                        child: ElevatedButton(
                          onPressed: widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            widget.notification.actionLabel!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (!widget.notification.isRead)
                      IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.done_all),
                        color: AppTheme.primaryBlue,
                        onPressed: widget.onMarkAsRead,
                        tooltip: 'Mark as read',
                      ),
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete),
                      color: AppTheme.errorRed,
                      onPressed: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

// ==================== Empty State ====================

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

// ==================== Error State ====================

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.length > 100 ? '${error.substring(0, 100)}...' : error,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ==================== Loading Skeleton ====================

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 200,
                  color: AppTheme.textHint.withOpacity(0.3),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  color: AppTheme.textHint.withOpacity(0.2),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 150,
                  color: AppTheme.textHint.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Loading Indicator ====================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
          ),
        ),
      ),
    );
  }
}
