import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/index.dart';
import '../../../../core/domain/models/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/utils/index.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              // Mark all as read logic would go here
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: AppSize.iconXLarge,
                    color: Colors.grey.shade400,
                  ),
                  AppLayout.gapMedium,
                  Text(
                    AppStrings.noNotifications,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationTile(notification: notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${AppErrors.loadingFailed}: $err')),
      ),
    );
  }
}

class NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const NotificationTile({required this.notification, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = NotificationUtils.getTypeColor(notification.type);
    final typeIcon = NotificationUtils.getTypeIcon(notification.type);
    final backgroundColor = NotificationUtils.getBackgroundColor(notification.type);

    return ListTile(
      onTap: () {
        // Mark as read
        ref.read(notificationRepositoryProvider).markAsRead(notification.id);
      },
      leading: CircleAvatar(
        backgroundColor: backgroundColor,
        child: Icon(typeIcon, color: typeColor),
      ),
      title: Text(notification.title),
      subtitle: Text(
        notification.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!notification.isRead)
            Container(
              width: AppSize.unreadBadge,
              height: AppSize.unreadBadge,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          AppLayout.gapSmall,
          Text(
            TimeFormatUtils.formatTimeDifference(notification.createdAt),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
