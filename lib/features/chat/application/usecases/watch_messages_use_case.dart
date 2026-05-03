import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class WatchMessagesUseCase implements StreamUseCase<List<MessageEntity>, String> {
  final IChatRepository _repository;

  WatchMessagesUseCase(this._repository);

  @override
  Stream<List<MessageEntity>> call(String chatId) {
    return _repository.watchMessages(chatId);
  }
}
