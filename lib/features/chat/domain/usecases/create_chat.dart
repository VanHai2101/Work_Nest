import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../repositories/index.dart';

class CreateOrGetChatParams {
  final String currentUserId;
  final String otherUserId;

  CreateOrGetChatParams({
    required this.currentUserId,
    required this.otherUserId,
  });
}

class CreateOrGetChatUseCase implements UseCase<String, CreateOrGetChatParams> {
  final IChatRepository _repository;

  CreateOrGetChatUseCase(this._repository);

  @override
  Future<Either<OperationState, String>> call(CreateOrGetChatParams params) async {
    try {
      final chatId = await _repository.createOrGetChat(
        params.currentUserId,
        params.otherUserId,
      );
      return Right(chatId);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
