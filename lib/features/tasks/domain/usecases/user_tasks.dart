import '../entities/index.dart';
import '../repositories/index.dart';

class GetUserAssignedTasksUseCase {
  final TaskRepository _repository;

  GetUserAssignedTasksUseCase(this._repository);

  Stream<List<TaskEntity>> call(String userId) {
    return _repository.getUserAssignedTasks(userId);
  }
}
