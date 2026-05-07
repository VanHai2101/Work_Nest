import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/email_otp_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

abstract class OtpState {}

/// Chưa làm gì
class OtpInitial extends OtpState {}

/// Đang gửi email hoặc đang xác minh
class OtpLoading extends OtpState {}

/// Đã gửi email thành công — chờ user nhập mã
class OtpSent extends OtpState {
  final String maskedEmail; // VD: "ho***@gmail.com"
  OtpSent(this.maskedEmail);
}

/// Xác minh OTP thành công
class OtpVerified extends OtpState {}

/// Lỗi (gửi thất bại, sai mã, hết hạn, ...)
class OtpError extends OtpState {
  final String message;
  OtpError(this.message);
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class OtpNotifier extends StateNotifier<OtpState> {
  final EmailOtpService _service;

  OtpNotifier(this._service) : super(OtpInitial());

  String? _currentUserId;

  /// Bước 1: Gửi OTP đến email của user hiện tại
  Future<void> sendOtp({required String purpose, required String purposeLabel}) async {
    state = OtpLoading();
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = OtpError('Bạn chưa đăng nhập.');
        return;
      }
      _currentUserId = user.uid;

      // Tạo và lưu OTP vào Firestore
      final code = await _service.createAndSaveOtp(
        userId: user.uid,
        email: user.email ?? '',
        purpose: purpose,
      );

      // Gửi email
      await _service.sendOtpEmail(
        toEmail: user.email ?? '',
        displayName: user.displayName ?? 'bạn',
        otpCode: code,
        purposeLabel: purposeLabel,
      );

      state = OtpSent(_maskEmail(user.email ?? ''));
    } on Exception catch (e) {
      state = OtpError(e.toString().replaceAll('Exception: ', ''));
    } catch (e) {
      state = OtpError('Không thể gửi email. Vui lòng thử lại.');
    }
  }

  /// Bước 2: Xác minh mã OTP user nhập vào
  Future<bool> verifyOtp({
    required String code,
    required String purpose,
  }) async {
    if (_currentUserId == null) {
      state = OtpError('Phiên hết hạn. Vui lòng gửi lại mã.');
      return false;
    }
    state = OtpLoading();
    try {
      await _service.verifyOtp(
        userId: _currentUserId!,
        inputCode: code,
        purpose: purpose,
      );
      state = OtpVerified();
      return true;
    } on OtpExpiredException catch (e) {
      state = OtpError(e.message);
      return false;
    } on OtpWrongException catch (e) {
      state = OtpError(e.message);
      return false;
    } on OtpBlockedException catch (e) {
      state = OtpError(e.message);
      return false;
    } on OtpNotFoundException catch (e) {
      state = OtpError(e.message);
      return false;
    } catch (e) {
      state = OtpError('Xác minh thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  Future<void> clearOtp() async {
    if (_currentUserId != null) {
      await _service.clearOtp(_currentUserId!);
    }
    state = OtpInitial();
  }

  void reset() => state = OtpInitial();

  // ── Helper: che email VD: ho***@gmail.com ────────────────────────────────────
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final emailOtpServiceProvider = Provider<EmailOtpService>(
  (ref) => EmailOtpService(),
);

final otpNotifierProvider =
    StateNotifierProvider.autoDispose<OtpNotifier, OtpState>((ref) {
  return OtpNotifier(ref.watch(emailOtpServiceProvider));
});
