import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/data/repositories/index.dart';

/// UseCase tạo task mới
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<String> call(TaskEntity task) {
    return _repository.createTask(
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
