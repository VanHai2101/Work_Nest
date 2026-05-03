abstract class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('Email này đã được sử dụng cho tài khoản khác.');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.');
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Email hoặc mật khẩu không đúng. Vui lòng thử lại.');
}

class WrongPasswordException extends AuthException {
  const WrongPasswordException()
      : super('Mật khẩu hiện tại không đúng. Vui lòng kiểm tra lại.');
}

class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
      : super('Phiên đăng nhập đã hết hạn. Vui lòng xác thực lại để tiếp tục.');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('Không tìm thấy tài khoản. Vui lòng đăng nhập lại.');
}

class InvalidOtpException extends AuthException {
  const InvalidOtpException()
      : super('Mã xác thực không đúng hoặc đã hết hạn. Vui lòng thử lại.');
}

/// Ném ra khi đăng nhập nhưng tài khoản đã bật 2FA.
/// Chứa [resolver] và [enrollmentId] để hoàn thành xác thực TOTP.
class MfaRequiredException extends AuthException {
  final dynamic resolver;
  final String enrollmentId;

  MfaRequiredException({
    required this.resolver,
    required this.enrollmentId,
  }) : super('Tài khoản của bạn đã bật xác thực 2 yếu tố.');
}

class UnknownAuthException extends AuthException {
  UnknownAuthException([String? msg])
      : super(msg ?? 'Đã có lỗi không xác định. Vui lòng thử lại.');
}
