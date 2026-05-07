import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/index.dart';

class WatchGroupMessagesUseCase implements StreamUseCase<List<MessageEntity>, String> {
  final IChatRepository _repository;

  WatchGroupMessagesUseCase(this._repository);

  @override
  Stream<List<MessageEntity>> call(String groupId) {
    return _repository.watchGroupMessages(groupId);
  }
}
