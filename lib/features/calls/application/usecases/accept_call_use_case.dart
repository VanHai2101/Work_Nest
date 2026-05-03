import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/repositories/call_repository.dart';

class AcceptCallParams {
  final String callId;
  final Map<String, dynamic> answer;

  AcceptCallParams({required this.callId, required this.answer});
}

class AcceptCallUseCase implements UseCase<void, AcceptCallParams> {
  final CallRepository _repository;

  AcceptCallUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(AcceptCallParams params) async {
    try {
      await _repository.acceptCall(params.callId, params.answer);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
