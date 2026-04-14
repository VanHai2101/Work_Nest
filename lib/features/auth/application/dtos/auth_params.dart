// tham số cho việc đăng ký tài khoản
class SingUpParams {
  const SingUpParams({
    required this.displayName,
    required this.password,
    required this.fullName,
  });

  final String displayName;
  final String password;
  final String fullName;
}

// tham số cho việc đăng nhập tài khoản
class SignInParams {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;
}
