class NotificationEntity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String actorId;
  final String actorName;
  final String? actorPhotoURL;
  final bool isRead;
  final DateTime createdAt;
  final String? relatedEntityId;
  final String? relatedEntityType;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.actorId,
    required this.actorName,
    this.actorPhotoURL,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityId,
    this.relatedEntityType,
  });
}
