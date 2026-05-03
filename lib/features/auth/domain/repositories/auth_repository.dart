import '../entities/user_entity.dart';
import '../entities/totp_secret_entity.dart';

abstract class IAuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> signUp(String email, String password, String fullName);

  /// Đăng nhập. Nếu tài khoản bật 2FA, ném [MfaRequiredException]
  /// chứa resolver để hoàn thành bước xác thực TOTP.
  Future<UserEntity?> signIn(String email, String password);

  Future<void> signOut();

  Future<void> reauthenticate(String email, String password);

  Future<void> changePassword(String newPassword);

  Future<void> deleteAccount();

  // ─── TOTP 2FA ────────────────────────────────────────────────────────────────

  /// Kiểm tra user hiện tại đã bật TOTP chưa.
  Future<bool> isTotpEnabled();

  /// Bước 1 của enrollment: tạo secret và trả về QR code URI.
  /// Gọi [verifyAndActivateTotp] với secret này để hoàn thành.
  Future<TotpSecretEntity> beginTotpEnrollment(String appName);

  /// Bước 2 của enrollment: xác minh OTP và kích hoạt 2FA.
  Future<void> verifyAndActivateTotp(TotpSecretEntity secret, String otp);

  /// Tắt TOTP (unenroll). Yêu cầu reauthenticate trước.
  Future<void> disableTotp();

  /// Hoàn thành đăng nhập khi MFA được yêu cầu.
  /// [resolver] lấy từ [MfaRequiredException].
  Future<UserEntity?> completeMfaSignIn(
    dynamic resolver,
    String enrollmentId,
    String otp,
  );
}
