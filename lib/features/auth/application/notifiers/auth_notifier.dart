import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../../../core/domain/states/index.dart';
import '../../presentation/providers/auth_providers.dart';
import '../usecases/index.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthNotifier extends StateNotifier<OperationState> {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final IAuthRepository _repository;

  AuthNotifier({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required IAuthRepository repository,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _repository = repository,
        super(const OperationInitial());

  Future<void> signUp(String email, String password, String fullName) async {
    state = const OperationLoading();
    final result = await _signUpUseCase.call(SignUpParams(
      email: email,
      password: password,
      fullName: fullName,
    ));
    state = result.fold((failure) => failure, (user) => OperationSuccess(user));
  }

  Future<void> signIn(String email, String password) async {
    state = const OperationLoading();
    final result = await _signInUseCase.call(SignInParams(
      email: email,
      password: password,
    ));
    state = result.fold((failure) => failure, (user) => OperationSuccess(user));
  }

  Future<void> signOut() async {
    state = const OperationLoading();
    final result = await _signOutUseCase.call(NoParams());
    state = result.fold(
      (failure) => failure,
      (_) => const OperationInitial(),
    );
  }

  Future<void> changePassword(String newPassword) async {
    state = const OperationLoading();
    try {
      await _repository.changePassword(newPassword);
      state = const OperationSuccess('Đổi mật khẩu thành công');
    } catch (e) {
      state = OperationFailure(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    state = const OperationLoading();
    try {
      await _repository.deleteAccount();
      state = const OperationInitial();
    } catch (e) {
      state = OperationFailure(e.toString());
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    state = const OperationLoading();
    try {
      await _repository.reauthenticate(email, password);
      state = const OperationSuccess('Xác thực thành công');
    } catch (e) {
      state = OperationFailure(e.toString());
    }
  }

  // TODO: Add more use cases for other actions
  
  void reset() => state = const OperationInitial();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, OperationState>((ref) {
      return AuthNotifier(
        signInUseCase: ref.watch(signInUseCaseProvider),
        signUpUseCase: ref.watch(signUpUseCaseProvider),
        signOutUseCase: ref.watch(signOutUseCaseProvider),
        repository: ref.watch(authRepositoryProvider),
      );
    });
