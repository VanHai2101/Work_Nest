import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(NoParams params) async {
    try {
      await _repository.signOut();
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
