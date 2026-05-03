import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// UseCase lấy tasks theo project
class GetTasksByProjectUseCase implements StreamUseCase<List<TaskEntity>, String> {
  const GetTasksByProjectUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Stream<List<TaskEntity>> call(String projectId) {
    return _repository.getProjectTasks(projectId);
  }
}
