import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/utils/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black87),
              title: const Text(
                'Thông báo',
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            )
          : null,
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
                    'No notifications yet',
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
        error: (err, stack) =>
            Center(child: Text('Failed to load notifications: $err')),
      ),
    );
  }
}

class NotificationTile extends ConsumerWidget {
  final NotificationEntity notification;

  const NotificationTile({required this.notification, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = NotificationUtils.getTypeColor(notification.type);
    final typeIcon = NotificationUtils.getTypeIcon(notification.type);
    final backgroundColor = NotificationUtils.getBackgroundColor(
      notification.type,
    );

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
