import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/index.dart';

class WatchGroupUseCase implements StreamUseCase<GroupEntity?, String> {
  final IChatRepository _repository;

  WatchGroupUseCase(this._repository);

  @override
  Stream<GroupEntity?> call(String groupId) {
    return _repository.watchGroup(groupId);
  }
}
