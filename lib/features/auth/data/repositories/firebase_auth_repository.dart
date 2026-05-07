import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/email_otp_service.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:work_nest/features/auth/domain/exceptions/auth_exceptions.dart';

import '../models/index.dart';

class FirebaseAuthRepository implements IAuthRepository {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User get _currentUser {
    final user = _auth.currentUser;
    if (user == null) throw const UserNotFoundException();
    return user;
  }

  @override
  Stream<UserEntity?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user != null
        ? UserEntity(
            id: user.uid,
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'User',
            createdAt: DateTime.now(),
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
      final uid = credential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'displayName': fullName,
        'email': email,
        'plan': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return UserEntity(
        id: uid,
        uid: uid,
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
    }
  }

  /// signIn xử lý cả trường hợp user bật 2FA
  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
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
    } on firebase_auth.FirebaseAuthMultiFactorException catch (e) {
      // User đã bật 2FA — trả resolver về cho Notifier để UI mở màn hình TOTP
      final totpFactor = e.resolver.hints.firstWhere(
        (h) => h.factorId == 'totp',
      );
      throw MfaRequiredException(
        resolver: e.resolver,
        enrollmentId: totpFactor.uid,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw const InvalidCredentialsException();
      }
      throw UnknownAuthException();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> reauthenticate(String email, String password) async {
    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _currentUser.reauthenticateWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const WrongPasswordException();
      }
      throw UnknownAuthException(e.message);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await _currentUser.updatePassword(newPassword);
      await _firestore.collection('users').doc(_currentUser.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const RequiresRecentLoginException();
      }
      if (e.code == 'weak-password') throw const WeakPasswordException();
      throw UnknownAuthException(e.message);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final uid = _currentUser.uid;
      await _firestore.collection('users').doc(uid).delete();
      await _currentUser.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const RequiresRecentLoginException();
      }
      throw UnknownAuthException(e.message);
    }
  }

  // ─── TOTP ────────────────────────────────────────────────────────────────────

  @override
  Future<bool> isTotpEnabled() async {
    final factors = await _currentUser.multiFactor.getEnrolledFactors();
    return factors.any((f) => f.factorId == 'totp');
  }

  @override
  Future<TotpSecretEntity> beginTotpEnrollment(String appName) async {
    try {
      final session = await _currentUser.multiFactor.getSession();
      final secret =
          await firebase_auth.TotpMultiFactorGenerator.generateSecret(session);
      final qrCodeUrl = await secret.generateQrCodeUrl(
        accountName: _currentUser.email ?? '',
        issuer: appName,
      );
      return TotpSecretEntity(
        secretKey: secret.secretKey,
        qrCodeUrl: qrCodeUrl,
        firebaseSecret: secret,
      );
    } catch (e) {
      throw UnknownAuthException('Không thể khởi tạo 2FA. Vui lòng thử lại.');
    }
  }

  @override
  Future<void> verifyAndActivateTotp(
    TotpSecretEntity secret,
    String otp,
  ) async {
    try {
      final assertion =
          await firebase_auth
              .TotpMultiFactorGenerator.getAssertionForEnrollment(
            secret.firebaseSecret,
            otp,
          );
      await _currentUser.multiFactor.enroll(
        assertion,
        displayName: 'Google Authenticator',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw const InvalidOtpException();
      }
      throw UnknownAuthException(e.message);
    }
  }

  @override
  Future<void> disableTotp() async {
    try {
      final factors = await _currentUser.multiFactor.getEnrolledFactors();
      final totpFactor = factors.firstWhere((f) => f.factorId == 'totp');
      await _currentUser.multiFactor.unenroll(multiFactorInfo: totpFactor);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const RequiresRecentLoginException();
      }
      throw UnknownAuthException(e.message);
    }
  }

  @override
  Future<UserEntity?> completeMfaSignIn(
    dynamic resolver,
    String enrollmentId,
    String otp,
  ) async {
    try {
      final mfaResolver = resolver as firebase_auth.MultiFactorResolver;
      final assertion = await firebase_auth
          .TotpMultiFactorGenerator.getAssertionForSignIn(enrollmentId, otp);
      final credential = await mfaResolver.resolveSignIn(assertion);
      final uid = credential.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data(), id: userDoc.id).toEntity();
      }
      return UserEntity(
        id: uid,
        uid: uid,
        email: credential.user!.email ?? '',
        displayName: credential.user!.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        throw const InvalidOtpException();
      }
      throw UnknownAuthException(e.message);
    }
  }

  // ─── EMAIL OTP ───────────────────────────────────────────────────────────────

  final _otpService = EmailOtpService();

  /// Dùng email hash làm key để hỗ trợ pre-signup (chưa có UID)
  String _emailKey(String email) =>
      email.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  @override
  Future<void> sendEmailOTP(String email) async {
    final key = _emailKey(email);
    final code = await _otpService.createAndSaveOtp(
      userId: key,
      email: email,
      purpose: 'signup',
    );
    await _otpService.sendOtpEmail(
      toEmail: email,
      displayName: email.split('@').first,
      otpCode: code,
      purposeLabel: 'Đăng ký tài khoản WorkNest',
    );
  }

  @override
  Future<void> verifyEmailOTP(String email, String otp) async {
    final key = _emailKey(email);
    final ok = await _otpService.verifyOtp(
      userId: key,
      inputCode: otp,
      purpose: 'signup',
    );
    if (!ok) throw OtpNotFoundException();
  }
}
