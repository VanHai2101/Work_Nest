import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import '../repositories/auth_repository.dart';

class SendEmailOTPParams {
  final String email;
  const SendEmailOTPParams({required this.email});
}

class SendEmailOTPUseCase {
  final IAuthRepository _repository;
  SendEmailOTPUseCase(this._repository);

  Future<Either<OperationState, void>> call(SendEmailOTPParams params) async {
    try {
      await _repository.sendEmailOTP(params.email);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
