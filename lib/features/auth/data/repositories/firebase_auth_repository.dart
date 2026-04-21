import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../../application/exceptions/auth_exceptions.dart';
import '../models/index.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<UserEntity?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user != null
            ? UserEntity(
                id: user.uid,
                uid: user.uid,
                email: user.email ?? '',
                displayName: user.displayName ?? 'User',
                createdAt: DateTime.now(), // Fallback
                updatedAt: DateTime.now(),
              )
            : null,
      );

  @override
  Future<UserEntity?> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userUid = credential.user!.uid;
      final userData = {
        'uid': userUid,
        'displayName': fullName,
        'email': email,
        'plan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userUid).set(userData);

      return UserEntity(
        id: userUid,
        uid: userUid,
        email: email,
        displayName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
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
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data(), id: userDoc.id).toEntity();
      }

      return UserEntity(
        id: credential.user!.uid,
        uid: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
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
