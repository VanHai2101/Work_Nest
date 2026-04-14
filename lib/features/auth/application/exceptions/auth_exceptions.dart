abstract class AuthException implements Exception {
  const AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AuthException:$message';
}

// lỗi sai email/password
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
    : super(
        'email hoặc mật khẩu không chính xác',
        code: 'invalid-credentials',
      );
}

// email đã tồn tại
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
    : super('email đã tồn tại', code: 'email-already-in-use');
}

// mật khẩu yếu
class WeakPasswordException extends AuthException {
  const WeakPasswordException()
    : super('mật khẩu quá yếu', code: 'weak-password');
}

// lỗi không xác định
class UnknownAuthException extends AuthException {
  const UnknownAuthException()
    : super('lỗi không xác định', code: 'unknown');
}
