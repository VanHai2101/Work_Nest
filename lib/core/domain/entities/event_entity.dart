class EventEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String time;
  final String color;
  final String? taskId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? repeat;
  final String? reminder;
  final String? location;

  EventEntity({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.color,
    this.taskId,
    required this.createdAt,
    required this.updatedAt,
    this.repeat,
    this.reminder,
    this.location,
  });
}
