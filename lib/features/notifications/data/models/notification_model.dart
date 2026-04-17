import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../../../core/utils/index.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String actorId;
  final String actorName;
  final String? actorPhotoURL;
  final bool isRead;
  final Timestamp createdAt;
  final String? relatedEntityId;
  final String? relatedEntityType;

  NotificationModel({
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

  factory NotificationModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return NotificationModel.empty();
    return NotificationModel(
      id: id ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'Unknown',
      actorPhotoURL: json['actorPhotoURL'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: Parser.parseTimestamp(json['createdAt']),
      relatedEntityId: json['relatedEntityId'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) => NotificationModel(
    id: entity.id,
    userId: entity.userId,
    type: entity.type.name,
    title: entity.title,
    body: entity.body,
    actorId: entity.actorId,
    actorName: entity.actorName,
    actorPhotoURL: entity.actorPhotoURL,
    isRead: entity.isRead,
    createdAt: Timestamp.fromDate(entity.createdAt),
    relatedEntityId: entity.relatedEntityId,
    relatedEntityType: entity.relatedEntityType,
  );

  factory NotificationModel.empty() => NotificationModel(
    id: '',
    userId: '',
    type: 'other',
    title: '',
    body: '',
    actorId: '',
    actorName: '',
    isRead: false,
    createdAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type,
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

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    userId: userId,
    type: NotificationEntity.parseType(type),
    title: title,
    body: body,
    actorId: actorId,
    actorName: actorName,
    actorPhotoURL: actorPhotoURL,
    isRead: isRead,
    createdAt: createdAt.toDate(),
    relatedEntityId: relatedEntityId,
    relatedEntityType: relatedEntityType,
  );

  static List<NotificationModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  static List<NotificationEntity> toEntityList(List<NotificationModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
