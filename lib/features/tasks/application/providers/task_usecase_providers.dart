import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/features/tasks/domain/repositories/task_repository.dart';
import 'package:work_nest/features/tasks/data/repositories/firebase_task_repository.dart';
import '../usecases/index.dart';

/// Provider cung cấp TaskRepository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});

/// Provider cung cấp GetAllTasksUseCase
final getAllTasksUseCaseProvider = Provider<GetAllTasksUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetAllTasksUseCase(repository);
});

/// Provider cung cấp GetTasksByProjectUseCase
final getTasksByProjectUseCaseProvider = Provider<GetTasksByProjectUseCase>((
  ref,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTasksByProjectUseCase(repository);
});

/// Provider cung cấp GetTaskByIdUseCase
final getTaskByIdUseCaseProvider = Provider<GetTaskByIdUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return GetTaskByIdUseCase(repository);
});

/// Provider cung cấp CreateTaskUseCase
final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return CreateTaskUseCase(repository);
});

/// Provider cung cấp UpdateTaskUseCase
final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return UpdateTaskUseCase(repository);
});

/// Provider cung cấp DeleteTaskUseCase
final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return DeleteTaskUseCase(repository);
});

/// Provider cung cấp ToggleTaskCompletionUseCase
final toggleTaskCompletionUseCaseProvider =
    Provider<ToggleTaskCompletionUseCase>((ref) {
      final repository = ref.watch(taskRepositoryProvider);
      return ToggleTaskCompletionUseCase(repository);
    });
