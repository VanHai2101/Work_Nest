import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  @override
  Future<UserEntity?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data(), id: doc.id).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> getUserStream(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data(), id: doc.id).toEntity();
    });
  }

  @override
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

  @override
  Future<void> updateUserPlan({
    required String uid,
    required String plan,
    required DateTime expiresAt,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'plan': plan,
        'planExpiresAt': Timestamp.fromDate(expiresAt),
        'planUpdatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
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

  @override
  Future<void> updateUserStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Future<void> updateMfaStatus(String uid, bool enabled) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isEmailMfaEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }
}
