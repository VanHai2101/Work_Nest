import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_providers.dart';
import '../../domain/entities/index.dart';

class PresenceNotifier extends WidgetsBindingObserver {
  final Ref ref;
  bool _isInitialized = false;

  PresenceNotifier(this.ref);

  void init() {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    _updateStatus(true);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateStatus(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _updateStatus(false);
    }
  }

  Future<void> _updateStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await ref
          .read(userRepositoryProvider)
          .updateUserStatus(user.uid, isOnline);
    }
  }
}

/// Provider to initialize and persist the presence monitoring
final presenceProvider = Provider<PresenceNotifier>((ref) {
  final notifier = PresenceNotifier(ref);
  notifier.init();

  // Clean up on provider disposal
  ref.onDispose(() => notifier.dispose());

  return notifier;
});

/// Provider to watch a specific user's live online status
final userOnlineStatusProvider = StreamProvider.family<bool, String>((
  ref,
  uid,
) {
  return ref
      .watch(userRepositoryProvider)
      .getUserStream(uid)
      .map((user) => user?.isOnline ?? false);
});

/// Provider to watch a specific user's last seen time
final userLastSeenProvider = StreamProvider.family<DateTime?, String>((
  ref,
  uid,
) {
  return ref
      .watch(userRepositoryProvider)
      .getUserStream(uid)
      .map((user) => user?.lastSeen);
});
