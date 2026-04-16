import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/data/repositories/index.dart';

/// UseCase lấy tất cả tasks của user (đã được giao)
class GetAllTasksUseCase {
  const GetAllTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call(String userId) {
    return _repository.getUserAssignedTasks(userId);
  }
}
