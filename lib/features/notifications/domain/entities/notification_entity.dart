enum NotificationType {
  taskAssigned,
  taskCompleted,
  messageReceived,
  groupMessageReceived,
  projectCreated,
  projectInvited,
  callIncoming,
  callMissed,
  planUpgraded,
  other,
}

class NotificationEntity {
  final String id;
  final String userId;
  final NotificationType type;
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

  static NotificationType parseType(String? typeStr) {
    if (typeStr == null) return NotificationType.other;
    switch (typeStr) {
      case 'task_assigned':
      case 'taskAssigned':
        return NotificationType.taskAssigned;
      case 'task_completed':
      case 'taskCompleted':
        return NotificationType.taskCompleted;
      case 'new_message':
      case 'messageReceived':
        return NotificationType.messageReceived;
      case 'group_message':
      case 'groupMessageReceived':
        return NotificationType.groupMessageReceived;
      case 'project_created':
      case 'projectCreated':
        return NotificationType.projectCreated;
      case 'project_invited':
      case 'projectInvited':
        return NotificationType.projectInvited;
      default:
        try {
          return NotificationType.values.byName(typeStr);
        } catch (_) {
          return NotificationType.other;
        }
    }
  }
}
