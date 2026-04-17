import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase lấy tasks theo project
class GetTasksByProjectUseCase {
  const GetTasksByProjectUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call(String projectId) {
    return _repository.getProjectTasks(projectId);
  }
}
