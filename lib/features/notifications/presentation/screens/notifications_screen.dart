import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../shared/providers/providers.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scrollController = ScrollController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        ref.read(notificationsNotifierProvider(currentUser.uid).notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        body: Center(
          child: Text(
            'Please login to view notifications',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
        ),
      );
    }

    final notificationsState = ref.watch(notificationsNotifierProvider(currentUser.uid));

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.filter_list : Icons.filter_list_off,
              color: _showUnreadOnly ? AppColors.primary : AppColors.textSecondaryDark,
            ),
            onPressed: () {
              setState(() => _showUnreadOnly = !_showUnreadOnly);
              ref.read(notificationsNotifierProvider(currentUser.uid).notifier)
                  .applyFilter(NotificationFilter(unreadOnly: _showUnreadOnly));
            },
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimaryDark),
            color: AppColors.surfaceDark,
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  ref.read(notificationsNotifierProvider(currentUser.uid).notifier)
                      .markAllAsRead();
                  break;
                case 'delete_all':
                  _showDeleteAllConfirmation(currentUser.uid);
                  break;
                case 'settings':
                  _showNotificationSettings(currentUser.uid);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: AppColors.textSecondaryDark),
                    SizedBox(width: 12),
                    Text('Mark all as read', style: TextStyle(color: AppColors.textPrimaryDark)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('Delete all', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.textSecondaryDark),
                    SizedBox(width: 12),
                    Text('Settings', style: TextStyle(color: AppColors.textPrimaryDark)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(notificationsState, currentUser.uid),
    );
  }

  Widget _buildBody(NotificationsState state, String userId) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingWidget();
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(notificationsNotifierProvider(userId).notifier).refresh(),
      );
    }

    if (state.notifications.isEmpty) {
      return const EmptyStateWidget(
        title: 'No notifications',
        subtitle: 'You\'re all caught up!',
        icon: Icons.notifications_none,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationsNotifierProvider(userId).notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = state.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification, userId),
            onDismiss: () => _handleNotificationDismiss(notification, userId),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, String userId) {
    // Mark as read
    if (!notification.isRead) {
      ref.read(notificationsNotifierProvider(userId).notifier)
          .markAsRead(notification.id);
    }

    // Navigate to target
    final route = notification.targetRoute;
    if (route != null) {
      context.push(route);
    }
  }

  void _handleNotificationDismiss(NotificationModel notification, String userId) {
    ref.read(notificationsNotifierProvider(userId).notifier)
        .deleteNotification(notification.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo
            ref.read(notificationsNotifierProvider(userId).notifier).refresh();
          },
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text(
          'Delete all notifications?',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationsNotifierProvider(userId).notifier)
                  .deleteAllNotifications();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _NotificationSettingsSheet(userId: userId),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(color: AppColors.grey800, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppColors.textPrimaryDark,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.timeAgo,
                      style: const TextStyle(
                        color: AppColors.textMutedDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.eventReminder:
      case NotificationType.eventUpdate:
      case NotificationType.newEvent:
        return Icons.event;
      case NotificationType.eventCancelled:
        return Icons.event_busy;
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingReminder:
        return Icons.confirmation_number;
      case NotificationType.bookingCancelled:
        return Icons.cancel;
      case NotificationType.paymentReceived:
        return Icons.payment;
      case NotificationType.paymentFailed:
        return Icons.money_off;
      case NotificationType.orderPlaced:
      case NotificationType.orderConfirmed:
        return Icons.shopping_bag;
      case NotificationType.orderShipped:
        return Icons.local_shipping;
      case NotificationType.orderDelivered:
        return Icons.check_circle;
      case NotificationType.orderCancelled:
        return Icons.cancel;
      case NotificationType.jobPosted:
        return Icons.work;
      case NotificationType.applicationReceived:
      case NotificationType.applicationAccepted:
      case NotificationType.applicationRejected:
        return Icons.assignment;
      case NotificationType.newMessage:
        return Icons.chat;
      case NotificationType.newReview:
      case NotificationType.reviewResponse:
        return Icons.star;
      case NotificationType.accountVerified:
        return Icons.verified;
      case NotificationType.profileUpdate:
        return Icons.person;
      case NotificationType.systemAnnouncement:
        return Icons.campaign;
      case NotificationType.promotional:
        return Icons.local_offer;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.eventCancelled:
      case NotificationType.bookingCancelled:
      case NotificationType.orderCancelled:
      case NotificationType.paymentFailed:
      case NotificationType.applicationRejected:
        return AppColors.error;
      case NotificationType.bookingConfirmed:
      case NotificationType.orderDelivered:
      case NotificationType.applicationAccepted:
      case NotificationType.accountVerified:
        return AppColors.success;
      case NotificationType.promotional:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getIconBackgroundColor() {
    return _getIconColor().withOpacity(0.1);
  }
}

class _NotificationSettingsSheet extends ConsumerWidget {
  final String userId;

  const _NotificationSettingsSheet({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider(userId));

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          settingsAsync.when(
            data: (settings) => Column(
              children: [
                _SettingsTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  value: settings.pushEnabled,
                  onChanged: (value) {
                    // TODO: Update settings
                  },
                ),
                _SettingsTile(
                  title: 'Event Reminders',
                  subtitle: 'Get reminded about upcoming events',
                  value: settings.eventReminders,
                  onChanged: (value) {},
                ),
                _SettingsTile(
                  title: 'Booking Updates',
                  subtitle: 'Updates about your bookings',
                  value: settings.bookingUpdates,
                  onChanged: (value) {},
                ),
                _SettingsTile(
                  title: 'Order Updates',
                  subtitle: 'Updates about your orders',
                  value: settings.orderUpdates,
                  onChanged: (value) {},
                ),
                _SettingsTile(
                  title: 'Job Alerts',
                  subtitle: 'New job postings and application updates',
                  value: settings.jobAlerts,
                  onChanged: (value) {},
                ),
                _SettingsTile(
                  title: 'Chat Messages',
                  subtitle: 'New messages in your chats',
                  value: settings.chatMessages,
                  onChanged: (value) {},
                ),
                _SettingsTile(
                  title: 'Promotions',
                  subtitle: 'Special offers and promotions',
                  value: settings.promotions,
                  onChanged: (value) {},
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text(
              'Failed to load settings',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimaryDark),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
