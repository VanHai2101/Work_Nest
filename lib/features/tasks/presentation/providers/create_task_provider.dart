import 'task_uc_providers.dart';
import 'task_repo_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/constants/index.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/features/tasks/domain/entities/task_entity.dart';
// Removed circular index import

/// State cho màn hình Create Task
class CreateTaskState {
  const CreateTaskState({
    this.title = '',
    this.description = '',
    this.assigneeIds = const [],
    this.dueDate,
    this.dueTime,
    this.priority = 'medium',
    this.isLoading = false,
    this.error,
  });

  final String title;
  final String description;
  final List<String> assigneeIds;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final String priority;
  final bool isLoading;
  final String? error;

  bool get isValid =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      dueDate != null &&
      dueTime != null;

  String get dueDateLabel => dueDate == null
      ? 'Select date'
      : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';

  String get dueTimeLabel {
    if (dueTime == null) return 'Select time';
    final h = dueTime!.hour.toString().padLeft(2, '0');
    final m = dueTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  CreateTaskState copyWith({
    String? title,
    String? description,
    List<String>? assigneeIds,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    String? priority,
    bool? isLoading,
    String? error,
  }) {
    return CreateTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier quản lý trạng thái Create Task
class CreateTaskNotifier extends Notifier<CreateTaskState> {
  @override
  CreateTaskState build() => const CreateTaskState();

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setAssigneeIds(List<String> assigneeIds) {
    state = state.copyWith(assigneeIds: assigneeIds);
  }

  void setPriority(String priority) {
    state = state.copyWith(priority: priority);
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: state.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      state = state.copyWith(dueDate: date);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: state.dueTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      state = state.copyWith(dueTime: time);
    }
  }

  /// Tạo TaskEntity từ state hiện tại
  TaskEntity buildTaskEntity({required String projectId}) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final deadline = DateTime(
      state.dueDate!.year,
      state.dueDate!.month,
      state.dueDate!.day,
      state.dueTime!.hour,
      state.dueTime!.minute,
    );

    return TaskEntity(
      id: '', // Sẽ được gán khi lưu vào database
      title: state.title.trim(),
      description: state.description.trim(),
      assigneeIds: state.assigneeIds.isEmpty
          ? [currentUserId]
          : state.assigneeIds,
      creatorId: currentUserId,
      completed: false,
      dueDate: deadline,
      dueTime: state.dueTimeLabel,
      projectId: projectId,
      order: 0,
      createdAt: now,
      updatedAt: now,
      priority: state.priority,
      tags: const [],
      attachments: const [],
    );
  }

  /// Submit tạo task
  Future<String?> submit({required String projectId}) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return state.error;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final task = buildTaskEntity(projectId: projectId);
      final useCase = ref.read(createTaskUseCaseProvider);

      await useCase(task);

      state = state.copyWith(isLoading: false);
      return null; // Success
    } catch (e) {
      final errorMsg = 'Error creating task: $e';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return errorMsg;
    }
  }

  void reset() {
    state = const CreateTaskState();
  }
}

/// Provider cho Create Task
final createTaskProvider =
    NotifierProvider<CreateTaskNotifier, CreateTaskState>(
      CreateTaskNotifier.new,
    );
