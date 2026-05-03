import '../entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity?> getUserById(String uid);
  Stream<UserEntity?> getUserStream(String uid);
  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
    String? photoURL,
  });
  Future<void> updateUserPlan({
    required String uid,
    required String plan,
    required DateTime expiresAt,
  });
  Future<void> addFCMToken(String uid, String token);
  Future<void> updateUserStatus(String uid, bool isOnline);
  Future<void> updateMfaStatus(String uid, bool enabled);
  Future<void> deleteUser(String uid);
}
