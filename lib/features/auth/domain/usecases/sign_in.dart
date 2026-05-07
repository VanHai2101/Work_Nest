import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:work_nest/features/auth/domain/exceptions/auth_exceptions.dart';

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final IAuthRepository _repository;

  SignInUseCase(this._repository);

  @override
  Future<Either<OperationState, UserEntity>> call(SignInParams params) async {
    try {
      final user = await _repository.signIn(params.email, params.password);
      if (user == null) {
        return const Left(
          OperationFailure('Không thể đăng nhập. Vui lòng thử lại.'),
        );
      }
      return Right(user);
    } on AuthException catch (e) {
      if (e is MfaRequiredException) {
        // Đặc biệt cho 2FA, chúng ta có thể trả về một Success mang thông tin MFA
        // Hoặc một State riêng. Ở đây ta dùng OperationSuccess với data là Exception này.
        return Left(MfaRequiredState(e.resolver, e.enrollmentId));
      }
      return Left(OperationFailure(e.message));
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}

class MfaRequiredState extends OperationError {
  final dynamic resolver;
  final String enrollmentId;

  MfaRequiredState(this.resolver, this.enrollmentId);

  @override
  String get message => 'Yêu cầu xác thực 2 lớp';
}
