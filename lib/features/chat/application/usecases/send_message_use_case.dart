import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class SendMessageParams {
  final String chatId;
  final MessageEntity message;

  SendMessageParams({required this.chatId, required this.message});
}

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(SendMessageParams params) async {
    try {
      await _repository.sendMessage(params.chatId, params.message);
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
