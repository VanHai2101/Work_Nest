import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../application/exceptions/auth_exceptions.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user != null ? AuthUser(id: user.uid, email: user.email!) : null,
  );

  @override
  Future<AuthUser> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'displayName': fullName,
        'email': email,
        'plan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthUser(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const EmailAlreadyInUseException();
      }
      if (e.code == 'weak-password') throw const WeakPasswordException();
      throw UnknownAuthException();
    } catch (e) {
      throw UnknownAuthException();
    }
  }

  @override
  Future<AuthUser> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthUser(id: credential.user!.uid, email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw const InvalidCredentialsException();
      }
      throw UnknownAuthException();
    } catch (e) {
      throw UnknownAuthException();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
