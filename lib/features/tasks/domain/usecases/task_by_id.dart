import 'package:work_nest/features/tasks/domain/entities/index.dart';
import 'package:work_nest/features/tasks/domain/repositories/index.dart';

/// UseCase lấy task theo ID
class GetTaskByIdUseCase {
  const GetTaskByIdUseCase(this._repository);

  final TaskRepository _repository;

  Future<TaskEntity?> call(String taskId, {String? projectId}) {
    return _repository.getTaskById(taskId, projectId: projectId);
  }
}
