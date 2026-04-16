import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/models/index.dart';
import '../../../../core/providers/index.dart';
import 'call_screen.dart';

class IncomingCallScreen extends ConsumerWidget {
  final String callId;
  final String callerName;
  final String callerId;
  final CallType callType;

  const IncomingCallScreen({
    required this.callId,
    required this.callerName,
    required this.callerId,
    required this.callType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              // Caller info
              Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    child: Text(
                      callerName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    callType == CallType.video ? 'Video Call' : 'Audio Call',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reject button
                    FloatingActionButton.large(
                      onPressed: () async {
                        await ref
                            .read(callRepositoryProvider)
                            .updateCallStatus(callId, CallStatus.rejected);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      backgroundColor: Colors.red,
                      child: const Icon(
                        Icons.call_end,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    // Accept button
                    FloatingActionButton.large(
                      onPressed: () async {
                        await ref
                            .read(callRepositoryProvider)
                            .updateCallStatus(callId, CallStatus.accepted);

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => CallScreen(
                                callId: callId,
                                remoteUserId: callerName,
                              ),
                            ),
                          );
                        }
                      },
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.call,
                        size: 32,
                        color: Colors.white,
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
}
