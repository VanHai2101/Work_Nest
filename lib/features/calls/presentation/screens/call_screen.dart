/// Active call screen showing local and remote video streams.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../providers/call_provider.dart';
import '../../domain/entities/call_entity.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final call = callState.call;

    if (call == null) {
      return const Scaffold(
        body: Center(child: Text('Call Ended')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video
          RTCVideoView(
            callState.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),

          // Local Video (Miniature)
          if (call.type == CallType.video)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).padding.top + 20,
              width: 120,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Colors.black26,
                  child: RTCVideoView(
                    callState.localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            ),

          // Call Info & Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                Text(
                  call.status == CallStatus.accepted ? 'In Call' : 'Ringing...',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: callState.isMicOn ? Icons.mic : Icons.mic_off,
                      onPressed: () => ref.read(callProvider.notifier).toggleMic(),
                      color: callState.isMicOn ? Colors.white24 : Colors.red,
                    ),
                    _ControlButton(
                      icon: Icons.call_end,
                      onPressed: () => ref.read(callProvider.notifier).hangUp(),
                      color: Colors.red,
                      size: 70,
                    ),
                    if (call.type == CallType.video)
                      _ControlButton(
                        icon: callState.isCameraOn ? Icons.videocam : Icons.videocam_off,
                        onPressed: () => ref.read(callProvider.notifier).toggleCamera(),
                        color: callState.isCameraOn ? Colors.white24 : Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size * 0.5),
        onPressed: onPressed,
      ),
    );
  }
}
