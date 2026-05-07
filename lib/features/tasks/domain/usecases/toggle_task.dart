import 'package:work_nest/features/tasks/domain/repositories/index.dart';

/// UseCase toggle hoàn thành task
class ToggleTaskCompletionUseCase {
  const ToggleTaskCompletionUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String taskId, String projectId, bool completed) {
    return _repository.toggleTaskCompletion(taskId, projectId, completed);
  }
}
