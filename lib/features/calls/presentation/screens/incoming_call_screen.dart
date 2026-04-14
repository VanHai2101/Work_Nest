/// Incoming call overlay/screen allowing user to accept or reject.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/call_provider.dart';
import '../../domain/entities/call_entity.dart';
import 'call_screen.dart';

class IncomingCallScreen extends ConsumerWidget {
  final CallEntity call;

  const IncomingCallScreen({super.key, required this.call});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.blueGrey.shade900,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Caller Avatar Placeholder
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(
                call.type == CallType.video ? Icons.videocam : Icons.call,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Incoming ${call.type.name} Call',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User ${call.callerUid}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallAction(
                    icon: Icons.call_end,
                    label: 'Decline',
                    color: Colors.red,
                    onPressed: () => ref.read(callProvider.notifier).rejectCall(call.id),
                  ),
                  _CallAction(
                    icon: Icons.check,
                    label: 'Accept',
                    color: Colors.green,
                    onPressed: () async {
                      await ref.read(callProvider.notifier).acceptCall(call);
                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CallScreen()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CallAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 30),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
