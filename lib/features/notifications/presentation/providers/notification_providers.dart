import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_use_case_providers.dart';

// RE-EXPORT
export 'notification_repository_providers.dart';
export 'notification_use_case_providers.dart';

final userNotificationsProvider = StreamProvider<List<NotificationEntity>>((
  ref,
) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return ref
      .watch(getUserNotificationsUseCaseProvider)
      .call(user.uid);
});

final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0);

  return ref.watch(getUnreadNotificationsCountUseCaseProvider).call(user.uid);
});
