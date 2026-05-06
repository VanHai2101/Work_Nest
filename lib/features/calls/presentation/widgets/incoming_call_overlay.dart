import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/notifications/domain/entities/notification_entity.dart';
import '../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../features/calls/domain/entities/call_entity.dart'
    show CallType;

import 'package:work_nest/core/components/dynamic_island/island_models.dart';
import 'package:work_nest/core/components/dynamic_island/island_provider.dart';
import '../screens/incoming_call_screen.dart';

class IncomingCallOverlay extends ConsumerWidget {
  final Widget child;

  const IncomingCallOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for incoming calls
    ref.listen(userNotificationsProvider, (previous, next) {
      next.whenData((notifications) {
        // Find incoming call notifications
        NotificationEntity? incomingCall;
        for (final notification in notifications) {
          if (notification.type == NotificationType.callIncoming &&
              !notification.isRead) {
            incomingCall = notification;
            break;
          }
        }

        if (incomingCall != null && incomingCall.relatedEntityId != null) {
          // Trigger Dynamic Island for Call
          ref.read(islandProvider.notifier).changeState(
            IslandState.phoneCall,
            context: IslandContext(
              title: incomingCall.actorName,
              subtitle: 'Incoming Call...',
            ),
          );

          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, _, _) => IncomingCallScreen(
              callId: incomingCall!.relatedEntityId!,
              callerName: incomingCall.actorName,
              callerId: incomingCall.actorId,
              callType: CallType.video,
            ),
          );
        } else if (notifications.isNotEmpty) {
          // Show the latest unread notification in Dynamic Island
          final lastNotif = notifications.firstWhere(
            (n) => !n.isRead,
            orElse: () => notifications.first,
          );
          
          if (!lastNotif.isRead) {
            ref.read(islandProvider.notifier).showNotification(
              title: lastNotif.title,
              message: lastNotif.body,
            );
          }
        }

      });
    });

    return child;
  }
}
