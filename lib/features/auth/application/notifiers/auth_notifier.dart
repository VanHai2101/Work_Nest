import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/states/index.dart';
import '../../domain/repositories/auth_repository.dart';
import '../exceptions/auth_exceptions.dart';
import '../../presentation/providers/auth_providers.dart';

class AuthNotifier extends StateNotifier<OperationState> {
  final IAuthRepository _repository;

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
      state = const OperationFailure('Lỗi kết nối, vui lòng thử lại');
    }
  }

  Future<void> signOut() async {
    state = const OperationLoading();
    try {
      await _repository.signOut();
      state = const OperationInitial();
    } catch (e) {
      state = const OperationFailure('Không thể đăng xuất, vui lòng thử lại');
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, OperationState>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthNotifier(repository);
    });
