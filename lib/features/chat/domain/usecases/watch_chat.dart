import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/index.dart';

class WatchChatUseCase implements StreamUseCase<ChatEntity?, String> {
  final IChatRepository _repository;

  WatchChatUseCase(this._repository);

  @override
  Stream<ChatEntity?> call(String chatId) {
    return _repository.watchChat(chatId);
  }
}
