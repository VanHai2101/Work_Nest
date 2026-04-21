import '../entities/index.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getProjectTasks(String projectId);
  
  Stream<List<TaskEntity>> getUserAssignedTasks(String userId);
  
  Future<TaskEntity?> getTaskById(String taskId, {String? projectId});
  
  Future<String> createTask({
    required String title,
    required String description,
    required String creatorId,
    required String projectId,
    required DateTime dueDate,
    required String dueTime,
    required List<String> assigneeIds,
    String priority = 'medium',
    List<String> tags = const [],
  });
  
  Future<void> updateTask({
    required String taskId,
    required String projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    List<String>? assigneeIds,
    String? priority,
    List<String>? tags,
  });
  
  Future<void> toggleTaskCompletion(String taskId, String projectId, bool completed);
  
  Future<void> deleteTask(String taskId, String projectId);
}
