import 'package:work_nest/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signUp(String email, String password, String fullName);

  Future<AuthUser> signIn(String email, String password);

  Future<void> signOut();
}
