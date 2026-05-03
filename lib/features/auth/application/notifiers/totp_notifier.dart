import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/states/index.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/totp_secret_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../../presentation/providers/auth_providers.dart';

class TotpNotifier extends StateNotifier<OperationState> {
  final IAuthRepository _repository;

  TotpNotifier(this._repository) : super(const OperationInitial());

  Future<bool> checkIfEnabled() async {
    try {
      return await _repository.isTotpEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<TotpSecretEntity?> beginEnrollment() async {
    state = const OperationLoading();
    try {
      final secret = await _repository.beginTotpEnrollment('Work Nest');
      state = const OperationInitial();
      return secret;
    } on AuthException catch (e) {
      state = OperationFailure(e.message);
      return null;
    } catch (e) {
      state = const OperationFailure('Lỗi khởi tạo 2FA. Vui lòng thử lại.');
      return null;
    }
  }

  Future<bool> verifyAndActivate(TotpSecretEntity secret, String otp) async {
    state = const OperationLoading();
    try {
      await _repository.verifyAndActivateTotp(secret, otp);
      state = const OperationSuccess('Đã kích hoạt 2FA thành công!');
      return true;
    } on AuthException catch (e) {
      state = OperationFailure(e.message);
      return false;
    } catch (e) {
      state = const OperationFailure('Xác minh thất bại. Vui lòng thử lại.');
      return false;
    }
  }

  Future<bool> disableTotp() async {
    state = const OperationLoading();
    try {
      await _repository.disableTotp();
      state = const OperationSuccess('Đã tắt 2FA thành công!');
      return true;
    } on AuthException catch (e) {
      state = OperationFailure(e.message);
      return false;
    } catch (e) {
      state = const OperationFailure('Lỗi tắt 2FA. Vui lòng thử lại.');
      return false;
    }
  }

  void reset() => state = const OperationInitial();
}

final totpNotifierProvider =
    StateNotifierProvider<TotpNotifier, OperationState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return TotpNotifier(repository);
});
