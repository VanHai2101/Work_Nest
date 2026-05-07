import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/index.dart';

class WatchGroupsUseCase implements StreamUseCase<List<GroupEntity>, String> {
  final IChatRepository _repository;

  WatchGroupsUseCase(this._repository);

  @override
  Stream<List<GroupEntity>> call(String userId) {
    return _repository.watchGroups(userId);
  }
}
