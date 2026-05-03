import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/sign_in_use_case.dart';
import '../../application/usecases/sign_up_use_case.dart';
import '../../application/usecases/sign_out_use_case.dart';
import '../../application/usecases/get_auth_state_use_case.dart';
import '../../application/usecases/get_user_profile_use_case.dart';
import '../../application/usecases/complete_mfa_sign_in_use_case.dart';
import 'auth_repository_providers.dart';

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
