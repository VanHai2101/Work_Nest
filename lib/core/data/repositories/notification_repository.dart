import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/index.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get user notifications
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Create a new notification (Client-side workaround for Cách 2)
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
  }) async {
    final docRef = _firestore.collection('notifications').doc();
    final data = {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'actorId': actorId,
      'actorName': actorName,
      'actorPhotoURL': actorPhotoURL,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
    await docRef.set(data);
  }

  // Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final docs = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  Future<void> deleteAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final docs = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
