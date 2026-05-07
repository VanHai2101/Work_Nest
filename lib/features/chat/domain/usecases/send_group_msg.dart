import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/index.dart';

class SendGroupMessageParams {
  final String groupId;
  final MessageEntity message;

  SendGroupMessageParams({required this.groupId, required this.message});
}

class SendGroupMessageUseCase implements UseCase<void, SendGroupMessageParams> {
  final IChatRepository _repository;

  SendGroupMessageUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(SendGroupMessageParams params) async {
    try {
      await _repository.sendGroupMessage(params.groupId, params.message);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
