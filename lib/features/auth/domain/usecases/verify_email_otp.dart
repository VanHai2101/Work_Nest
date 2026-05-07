import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailOTPParams {
  final String email;
  final String otp;
  const VerifyEmailOTPParams({required this.email, required this.otp});
}

class VerifyEmailOTPUseCase {
  final IAuthRepository _repository;
  VerifyEmailOTPUseCase(this._repository);

  Future<Either<OperationState, void>> call(VerifyEmailOTPParams params) async {
    try {
      await _repository.verifyEmailOTP(params.email, params.otp);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
