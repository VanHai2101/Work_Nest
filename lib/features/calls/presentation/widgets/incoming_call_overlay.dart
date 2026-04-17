import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/notifications/domain/entities/notification_entity.dart';
import '../../../../features/notifications/presentation/providers/notification_providers.dart';
import '../../../../features/calls/domain/entities/call_entity.dart' show CallType; 

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
          if (notification.type == NotificationType.callIncoming && !notification.isRead) {
            incomingCall = notification;
            break;
          }
        }

        if (incomingCall != null && incomingCall.relatedEntityId != null) {
          final call = incomingCall;
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            pageBuilder: (context, _, __) => IncomingCallScreen(
              callId: call.relatedEntityId!,
              callerName: call.actorName,
              callerId: call.actorId,
              callType: CallType.video,
            ),
          );
        }
      });
    });

    return child;
  }
}


