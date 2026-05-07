import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../repositories/index.dart';

class MarkMessageAsReadParams {
  final String chatId;
  final String messageId;
  final String userId;
  final bool isGroup;

  MarkMessageAsReadParams({
    required this.chatId,
    required this.messageId,
    required this.userId,
    this.isGroup = false,
  });
}

class MarkMessageAsReadUseCase implements UseCase<void, MarkMessageAsReadParams> {
  final IChatRepository _repository;

  MarkMessageAsReadUseCase(this._repository);

  @override
  Future<Either<OperationState, void>> call(MarkMessageAsReadParams params) async {
    try {
      await _repository.markMessageAsRead(
        params.chatId,
        params.messageId,
        params.userId,
        isGroup: params.isGroup,
      );
      return const Right(null);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
