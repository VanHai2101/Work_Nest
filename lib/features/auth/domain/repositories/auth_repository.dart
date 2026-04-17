import '../entities/user_entity.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> signUp(String email, String password, String fullName);

  Future<UserEntity?> signIn(String email, String password);

  Future<void> signOut();
}
