import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase lấy task theo ID
class GetTaskByIdUseCase {
  const GetTaskByIdUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity?> call(String taskId, {String? projectId}) {
    return _repository.getTaskById(taskId, projectId: projectId);
  }
}
