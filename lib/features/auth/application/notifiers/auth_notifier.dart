import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/states/operation_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../exceptions/auth_exceptions.dart';
import '../providers/auth_providers.dart';

class AuthNotifier extends StateNotifier<OperationState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const OperationInitial());

  Future<void> signUp(String email, String password, String fullName) async {
    state = const OperationLoading();
    try {
      final user = await _repository.signUp(email, password, fullName);
      state = OperationSuccess(user);
    } on AuthException catch (e) {
      state = OperationFailure(e.message);
    } catch (e) {
      state = const OperationFailure('Đã có lỗi xảy ra vui lòng thử lại');
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const OperationLoading();
    try {
      final user = await _repository.signIn(email, password);
      state = OperationSuccess(user);
    } on AuthException catch (e) {
      state = OperationFailure(e.message);
    } catch (e) {
      state = const OperationFailure('Sai tài khoản hoặc mật khẩu');
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, OperationState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthNotifier(repository);
    });
