import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class WatchChatsUseCase implements StreamUseCase<List<ChatEntity>, String> {
  final IChatRepository _repository;

  WatchChatsUseCase(this._repository);

  @override
  Stream<List<ChatEntity>> call(String userId) {
    return _repository.watchChats(userId);
  }
}
