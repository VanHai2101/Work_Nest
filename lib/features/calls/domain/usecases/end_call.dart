import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/repositories/call_repository.dart';

class EndCallUseCase implements UseCase<void, String> {
  final CallRepository _repository;

  EndCallUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(String callId) async {
    try {
      await _repository.endCall(callId);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
