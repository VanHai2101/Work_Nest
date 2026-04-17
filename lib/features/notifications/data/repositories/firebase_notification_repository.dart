import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class FirebaseNotificationRepository implements INotificationRepository {
  final FirebaseFirestore _firestore;

  FirebaseNotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NotificationEntity>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), id: doc.id).toEntity())
          .toList();
    });
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final docs = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      const chunkSize = 500;
      for (var i = 0; i < docs.docs.length; i += chunkSize) {
        final batch = _firestore.batch();
        final chunk = docs.docs.sublist(i, min(i + chunkSize, docs.docs.length));
        for (var doc in chunk) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final docs = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      const chunkSize = 500;
      for (var i = 0; i < docs.docs.length; i += chunkSize) {
        final batch = _firestore.batch();
        final chunk = docs.docs.sublist(i, min(i + chunkSize, docs.docs.length));
        for (var doc in chunk) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
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
    try {
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
    } catch (e) {
      rethrow;
    }
  }
}
