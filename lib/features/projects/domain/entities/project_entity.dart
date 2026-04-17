class ProjectEntity {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final String status;
  final double progress;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? color;
  final List<String> tags;

  ProjectEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.color,
    this.tags = const [],
  });
}
