import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/call_entity.dart';
import '../../domain/repositories/call_repository.dart';

class StartCallUseCase implements UseCase<String, CallEntity> {
  final CallRepository _repository;

  StartCallUseCase(this._repository);

  @override
  Future<Either<OperationState, String>> call(CallEntity call) async {
    try {
      final callId = await _repository.startCall(call);
      return Right(callId);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
