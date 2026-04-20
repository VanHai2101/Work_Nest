import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/firebase_task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});

final projectTasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getProjectTasks(projectId);
});

final userAssignedTasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, userId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getUserAssignedTasks(userId);
});

final taskProvider = FutureProvider.family<TaskEntity?, ({String taskId, String? projectId})>((ref, args) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(args.taskId, projectId: args.projectId);
});
