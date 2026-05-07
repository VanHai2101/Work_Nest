import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:work_nest/features/auth/domain/exceptions/auth_exceptions.dart';

class SignUpParams {
  final String email;
  final String password;
  final String fullName;

  SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final IAuthRepository _repository;

  SignUpUseCase(this._repository);

  @override
  Future<Either<OperationState, UserEntity>> call(SignUpParams params) async {
    try {
      final user = await _repository.signUp(
        params.email,
        params.password,
        params.fullName,
      );
      if (user == null) {
        return const Left(OperationFailure('Không thể đăng ký. Vui lòng thử lại.'));
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(OperationFailure(e.message));
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
