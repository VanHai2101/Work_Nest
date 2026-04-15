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

    ref.listen(incomingCallStreamProvider, (previous, next) {
      final call = next.value;
      if (call != null) {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          pageBuilder: (context, _, _) => IncomingCallScreen(call: call),
        );
      }
    });

    return child;
  }
}
