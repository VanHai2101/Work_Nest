import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// UseCase tạo task mới
class CreateTaskUseCase {
  const CreateTaskUseCase(this.repository);

  final TaskRepository repository;

  Future<String> call(TaskEntity task) {
    return repository.createTask(
      title: task.title,
      description: task.description,
      creatorId: task.creatorId,
      projectId: task.projectId,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      assigneeIds: task.assigneeIds,
      priority: task.priority,
      tags: task.tags,
    );
  }
}
