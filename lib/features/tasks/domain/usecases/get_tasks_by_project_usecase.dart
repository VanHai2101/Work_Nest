import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/data/repositories/index.dart';

/// UseCase lấy tasks theo project
class GetTasksByProjectUseCase {
  const GetTasksByProjectUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<TaskEntity>> call(String projectId) {
    return _repository.getProjectTasks(projectId);
  }
}
