import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import 'task_use_case_providers.dart';
import 'task_repository_providers.dart';

// RE-EXPORT
export 'task_repository_providers.dart';
export 'task_use_case_providers.dart';

final projectTasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, projectId) {
  return ref.watch(getTasksByProjectUseCaseProvider).call(projectId);
});

// For other providers, we should refactor their use cases first.
// For now, I'll keep them pointing to the repository but marked for refactoring.
// In a real scenario, I'd refactor all use cases first.

final userAssignedTasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, userId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getUserAssignedTasks(userId);
});

final taskProvider = FutureProvider.family<TaskEntity?, ({String taskId, String? projectId})>((ref, args) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(args.taskId, projectId: args.projectId);
});
