import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'index.dart';

/// State cho màn hình Edit Task
class EditTaskState {
  const EditTaskState({
    required this.taskId,
    required this.projectId,
    this.title = '',
    this.description = '',
    this.assigneeIds = const [],
    this.dueDate,
    this.dueTime,
    this.priority = 'medium',
    this.isLoading = false,
    this.error,
  });

  final String taskId;
  final String projectId;
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
      ? ''
      : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';

  String get dueTimeLabel {
    if (dueTime == null) return '';
    return '${dueTime!.hour.toString().padLeft(2, '0')}:${dueTime!.minute.toString().padLeft(2, '0')}';
  }

  EditTaskState copyWith({
    String? taskId,
    String? projectId,
    String? title,
    String? description,
    List<String>? assigneeIds,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    String? priority,
    bool? isLoading,
    String? error,
  }) {
    return EditTaskState(
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
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

/// Notifier quản lý trạng thái Edit Task
class EditTaskNotifier extends Notifier<EditTaskState> {
  @override
  EditTaskState build() {
    return const EditTaskState(taskId: '', projectId: '');
  }

  /// Khởi tạo state với task entity hiện có
  void initialize(TaskEntity task) {
    state = EditTaskState(
      taskId: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      assigneeIds: task.assigneeIds,
      dueDate: task.dueDate,
      dueTime: _parseTimeOfDay(task.dueTime),
      priority: task.priority,
    );
  }

  /// Chuyển đổi string thành TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Nếu parse lỗi, trả về null
    }
    return null;
  }

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

  /// Submit cập nhật task
  Future<String?> submit() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return state.error;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final dueDateTime = DateTime(
        state.dueDate!.year,
        state.dueDate!.month,
        state.dueDate!.day,
        state.dueTime!.hour,
        state.dueTime!.minute,
      );

      final updatedTask = TaskEntity(
        id: state.taskId,
        title: state.title.trim(),
        description: state.description.trim(),
        assigneeIds: state.assigneeIds,
        creatorId: '', // Không thay đổi creator
        completed: false, // Không thay đổi completed
        dueDate: dueDateTime,
        dueTime: state.dueTimeLabel,
        projectId: state.projectId,
        order: 0, // Không thay đổi order
        createdAt: DateTime.now(), // Sẽ bị ignore bởi repository
        updatedAt: DateTime.now(),
        priority: state.priority,
        tags: const [],
        attachments: const [],
      );

      final useCase = ref.read(updateTaskUseCaseProvider);
      await useCase(updatedTask);

      state = state.copyWith(isLoading: false);
      return null; // Success
    } catch (e) {
      final errorMsg = 'Error updating task: $e';
      state = state.copyWith(isLoading: false, error: errorMsg);
      return errorMsg;
    }
  }
}

/// Provider cho Edit Task
final editTaskProvider = NotifierProvider<EditTaskNotifier, EditTaskState>(
  EditTaskNotifier.new,
);
