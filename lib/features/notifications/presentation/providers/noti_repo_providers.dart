import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/firebase_notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return FirebaseNotificationRepository();
});
