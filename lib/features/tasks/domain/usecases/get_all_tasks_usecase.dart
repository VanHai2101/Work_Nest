import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase lấy tất cả tasks của user (đã được giao)
class GetAllTasksUseCase {
  const GetAllTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call(String userId) {
    return _repository.getUserAssignedTasks(userId);
  }
}
