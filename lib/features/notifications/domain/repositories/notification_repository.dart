import '../entities/index.dart';

abstract class INotificationRepository {
  Stream<List<NotificationEntity>> getUserNotifications(String userId);
  Stream<int> getUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications(String userId);
  
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required String actorId,
    required String actorName,
    String? actorPhotoURL,
    String? relatedEntityId,
    String? relatedEntityType,
  });
}
