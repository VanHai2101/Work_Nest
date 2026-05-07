import 'task_uc_providers.dart';
import 'task_repo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/index.dart';
// Removed circular index import

/// Provider lấy tất cả tasks của user hiện tại
final userTasksProvider = StreamProvider.autoDispose<List<TaskEntity>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final useCase = ref.watch(getAllTasksUseCaseProvider);
  return useCase(userId);
});

/// Provider lấy tasks theo project (tham số là projectId)
final projectTasksProvider = StreamProvider.autoDispose
    .family<List<TaskEntity>, String>((ref, projectId) {
      final useCase = ref.watch(getTasksByProjectUseCaseProvider);
      return useCase(projectId);
    });

/// Provider lấy completed tasks (filter từ userTasksProvider)
final completedTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final tasks = ref
      .watch(userTasksProvider)
      .maybeWhen(data: (data) => data, orElse: () => <TaskEntity>[]);
  return tasks.where((t) => t.completed).toList();
});

/// Provider lấy incomplete tasks (filter từ userTasksProvider)
final incompleteTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final tasks = ref
      .watch(userTasksProvider)
      .maybeWhen(data: (data) => data, orElse: () => <TaskEntity>[]);
  return tasks.where((t) => !t.completed).toList();
});

/// Provider lấy overdue tasks (quá hạn)
final overdueTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final tasks = ref.watch(incompleteTasksProvider);
  final now = DateTime.now();
  return tasks.where((t) => t.dueDate.isBefore(now)).toList();
});

/// Provider đếm tasks
final taskCountProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref
      .watch(userTasksProvider)
      .maybeWhen(data: (data) => data, orElse: () => <TaskEntity>[]);
  return tasks.length;
});

/// Provider đếm completed tasks
final completedTaskCountProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(completedTasksProvider);
  return tasks.length;
});

/// Provider lấy tasks được gán cho user
final userAssignedTasksProvider = StreamProvider.family<List<TaskEntity>, String>((ref, userId) {
  return ref.watch(getUserAssignedTasksUseCaseProvider).call(userId);
});

/// Provider lấy chi tiết một task
final taskProvider = FutureProvider.family<TaskEntity?, ({String taskId, String? projectId})>((ref, args) {
  return ref.watch(getTaskByIdUseCaseProvider).call(args.taskId, projectId: args.projectId);
});
