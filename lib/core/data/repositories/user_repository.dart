import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/entities/index.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  Future<UserEntity?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return _parseUserEntity(doc);
    } catch (e) {
      return null;
    }
  }

  Stream<UserEntity?> getUserStream(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return _parseUserEntity(doc);
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'displayName': displayName,
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserPlan({
    required String uid,
    required String plan,
    required DateTime expiresAt,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'plan': plan,
        'planExpiresAt': expiresAt,
        'planUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Add FCM token
  Future<void> addFCMToken(String uid, String token) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  UserEntity _parseUserEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEntity(
      id: doc.id,
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      plan: data['plan'] ?? 'free',
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
      planExpiresAt: (data['planExpiresAt'] as Timestamp?)?.toDate(),
      planUpdatedAt: (data['planUpdatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
