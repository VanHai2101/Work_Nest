import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/get_user_notifications_use_case.dart';
import '../../application/usecases/get_unread_notifications_count_use_case.dart';
import 'notification_repository_providers.dart';

final getUserNotificationsUseCaseProvider = Provider<GetUserNotificationsUseCase>((ref) {
  return GetUserNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final getUnreadNotificationsCountUseCaseProvider = Provider<GetUnreadNotificationsCountUseCase>((ref) {
  return GetUnreadNotificationsCountUseCase(ref.watch(notificationRepositoryProvider));
});
