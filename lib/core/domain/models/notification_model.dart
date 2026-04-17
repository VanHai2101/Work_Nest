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

class AppNotification {
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

  AppNotification({
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

  static NotificationType _parseType(String? typeStr) {
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
      default:
        try {
          return NotificationType.values.byName(typeStr);
        } catch (_) {
          return NotificationType.other;
        }
    }
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      userId: map['userId'] ?? '',
      type: _parseType(map['type']),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      actorId: map['actorId'] ?? '',
      actorName: map['actorName'] ?? 'Unknown',
      actorPhotoURL: map['actorPhotoURL'],
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      relatedEntityId: map['relatedEntityId'],
      relatedEntityType: map['relatedEntityType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'actorId': actorId,
      'actorName': actorName,
      'actorPhotoURL': actorPhotoURL,
      'isRead': isRead,
      'createdAt': createdAt,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? actorId,
    String? actorName,
    String? actorPhotoURL,
    bool? isRead,
    DateTime? createdAt,
    String? relatedEntityId,
    String? relatedEntityType,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorPhotoURL: actorPhotoURL ?? this.actorPhotoURL,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
    );
  }
}
