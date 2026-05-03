import 'package:work_nest/features/tasks/domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../repositories/task_repository.dart';

/// UseCase cập nhật task
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(TaskEntity task) {
    return _repository.updateTask(
      taskId: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      assigneeIds: task.assigneeIds,
      priority: task.priority,
      tags: task.tags,
    );
  }
}
