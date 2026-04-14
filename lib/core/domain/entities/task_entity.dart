class TaskEntity {
  final String id;
  final String title;
  final String description;
  final List<String> assigneeIds;
  final String creatorId;
  final bool completed;
  final DateTime dueDate;
  final String dueTime;
  final String projectId;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String priority;
  final List<String> tags;
  final List<String> attachments;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeIds,
    required this.creatorId,
    required this.completed,
    required this.dueDate,
    required this.dueTime,
    required this.projectId,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.priority = 'medium',
    this.tags = const [],
    this.attachments = const [],
  });
}
