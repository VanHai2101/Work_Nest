/// Global widget that listens for incoming calls and displays the acceptance UI.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/call_provider.dart';
import '../screens/incoming_call_screen.dart';
import '../../../../core/providers/auth_provider.dart';

class IncomingCallOverlay extends ConsumerWidget {
  final Widget child;

  const IncomingCallOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    
    if (userId == null) return child;

    // Listen for incoming calls using the StreamProvider
    ref.listen(incomingCallStreamProvider, (previous, next) {
      final call = next.value;
      if (call != null) {
        // Show incoming call screen as a modal overlay
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          pageBuilder: (context, _, __) => IncomingCallScreen(call: call),
        );
      }
    });

    return child;
  }
}
