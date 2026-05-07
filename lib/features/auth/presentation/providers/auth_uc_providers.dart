import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/auth_state.dart';
import '../../domain/usecases/user_profile.dart';
import '../../domain/usecases/mfa_sign_in.dart';
import '../../domain/usecases/send_email_otp.dart';
import '../../domain/usecases/verify_email_otp.dart';
import 'auth_repo_providers.dart';

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(userRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  return GetAuthStateUseCase(ref.watch(authRepositoryProvider));
});

final completeMfaSignInUseCaseProvider = Provider<CompleteMfaSignInUseCase>((ref) {
  return CompleteMfaSignInUseCase(ref.watch(authRepositoryProvider));
});

final sendEmailOTPUseCaseProvider = Provider<SendEmailOTPUseCase>((ref) {
  return SendEmailOTPUseCase(ref.watch(authRepositoryProvider));
});

final verifyEmailOTPUseCaseProvider = Provider<VerifyEmailOTPUseCase>((ref) {
  return VerifyEmailOTPUseCase(ref.watch(authRepositoryProvider));
});
