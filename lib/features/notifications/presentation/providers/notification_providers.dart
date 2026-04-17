import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/firebase_notification_repository.dart';

// 1. Repository Provider
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return FirebaseNotificationRepository();
});

// 2. User Notifications Stream Provider
final userNotificationsProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  
  return ref.watch(notificationRepositoryProvider).getUserNotifications(user.uid);
});

// 3. Unread Count Stream Provider
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(0);
  
  return ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid);
});
