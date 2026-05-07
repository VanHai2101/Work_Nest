import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/user_notifications.dart';
import '../../domain/usecases/unread_count.dart';

import 'noti_repo_providers.dart';

final getUserNotificationsUseCaseProvider = Provider<GetUserNotificationsUseCase>((ref) {
  return GetUserNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final getUnreadNotificationsCountUseCaseProvider = Provider<GetUnreadNotificationsCountUseCase>((ref) {
  return GetUnreadNotificationsCountUseCase(ref.watch(notificationRepositoryProvider));
});
