import '../repositories/task_repository.dart';

/// UseCase xóa task
class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String taskId, String projectId) {
    return _repository.deleteTask(taskId, projectId);
  }
}
