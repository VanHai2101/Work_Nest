import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'index.dart';

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
final projectTasksProvider = StreamProvider.autoDispose.family<
  List<TaskEntity>,
  String
>((ref, projectId) {
  final useCase = ref.watch(getTasksByProjectUseCaseProvider);
  return useCase(projectId);
});

/// Provider lấy completed tasks (filter từ userTasksProvider)
final completedTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final tasks = ref.watch(userTasksProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <TaskEntity>[],
  );
  return tasks.where((t) => t.completed).toList();
});

/// Provider lấy incomplete tasks (filter từ userTasksProvider)
final incompleteTasksProvider = Provider.autoDispose<List<TaskEntity>>((ref) {
  final tasks = ref.watch(userTasksProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <TaskEntity>[],
  );
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
  final tasks = ref.watch(userTasksProvider).maybeWhen(
    data: (data) => data,
    orElse: () => <TaskEntity>[],
  );
  return tasks.length;
});

/// Provider đếm completed tasks
final completedTaskCountProvider = Provider.autoDispose<int>((ref) {
  final tasks = ref.watch(completedTasksProvider);
  return tasks.length;
});
