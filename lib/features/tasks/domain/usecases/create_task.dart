import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// UseCase tạo task mới
class CreateTaskUseCase implements UseCase<String, TaskEntity> {
  const CreateTaskUseCase(this.repository);

  final TaskRepository repository;

  @override
  Future<Either<OperationState, String>> call(TaskEntity task) async {
    try {
      final id = await repository.createTask(
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
      return Right(id);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
