import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/features/calls/presentation/providers/call_provider.dart';
import '../../domain/entities/call_entity.dart';

import '../../../../core/providers/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/utils/index.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String callId;
  final String remoteUserId;

  const CallScreen({required this.callId, required this.remoteUserId, Key? key})
    : super(key: key);

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callProvider);
    final call = callState.call;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (call == null) {
      return const Scaffold(body: Center(child: Text('No active call')));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Remote video
          Container(
            color: Colors.black,
            child: const Center(
              child: CircleAvatar(
                radius: 80,
                child: Icon(Icons.person, size: 80),
              ),
            ),
          ),
          // Local video (small)
          Positioned(
            bottom: 100,
            right: AppPadding.medium,
            child: Container(
              width: AppSize.videoMiniWidth,
              height: AppSize.videoMiniHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: AppBorderRadius.medium,
              ),
              child: const Center(
                child: CircleAvatar(child: Icon(Icons.person, size: 40)),
              ),
            ),
          ),
          // Call info
          Positioned(
            top: 60,
            left: AppPadding.medium,
            right: AppPadding.medium,
            child: Column(
              children: [
                Text(
                  'Calling ${widget.remoteUserId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppLayout.gapSmall,
                _buildCallDuration(call),
              ],
            ),
          ),
          // Controls
          Positioned(
            bottom: AppPadding.large,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                    color: _isMuted ? Colors.red : Colors.white,
                  ),
                  AppLayout.horizontalGapMedium,
                  // Camera toggle
                  _buildControlButton(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    label: _isCameraOff ? 'Camera Off' : 'Camera',
                    onPressed: () {
                      setState(() => _isCameraOff = !_isCameraOff);
                    },
                    color: _isCameraOff ? Colors.red : Colors.white,
                  ),
                  AppLayout.horizontalGapMedium,
                  // Speaker toggle
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_mute,
                    label: _isSpeakerOn ? 'Speaker' : 'Speaker',
                    onPressed: () {
                      setState(() => _isSpeakerOn = !_isSpeakerOn);
                    },
                    color: _isSpeakerOn ? Colors.white : Colors.grey,
                  ),
                  AppLayout.horizontalGapMedium,
                  // End call
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: AppStrings.endCall,
                    onPressed: () async {
                      await ref.read(callProvider.notifier).hangUp();
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    backgroundColor: Colors.red,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? color,
  }) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: backgroundColor ?? Colors.grey.shade700,
          child: Icon(icon, color: color ?? Colors.white),
        ),
        AppLayout.gapSmall,
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildCallDuration(CallEntity call) {
    if (call.status == CallStatus.ringing) {
      return const Text(
        AppStrings.ringing,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    return StreamBuilder<Duration>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) {
        return DateTime.now().difference(call.createdAt);
      }),
      builder: (context, snapshot) {
        final duration = snapshot.data ?? const Duration(seconds: 0);
        return Text(
          TimeFormatUtils.formatDuration(duration),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        );
      },
    );
  }
}
