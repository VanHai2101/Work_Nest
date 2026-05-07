import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:work_nest/features/auth/domain/exceptions/auth_exceptions.dart';


class CompleteMfaSignInParams {
  final dynamic resolver;
  final String enrollmentId;
  final String otp;

  CompleteMfaSignInParams({
    required this.resolver,
    required this.enrollmentId,
    required this.otp,
  });
}

class CompleteMfaSignInUseCase implements UseCase<UserEntity, CompleteMfaSignInParams> {
  final IAuthRepository _repository;

  CompleteMfaSignInUseCase(this._repository);

  @override
  Future<Either<OperationState, UserEntity>> call(CompleteMfaSignInParams params) async {
    try {
      final user = await _repository.completeMfaSignIn(
        params.resolver,
        params.enrollmentId,
        params.otp,
      );
      if (user == null) {
        return const Left(OperationFailure('Xác thực thất bại.'));
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(OperationFailure(e.message));
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
