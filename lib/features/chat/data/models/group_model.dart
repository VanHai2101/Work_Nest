import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_entity.dart';
import '../../../../core/utils/parser.dart';

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final String? photoURL;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? lastMessage;
  final Timestamp? lastMessageAt;
  final Map<String, int> unreadCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.photoURL,
    required this.adminIds,
    required this.memberIds,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return GroupModel.empty();
    return GroupModel(
      id: id ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      photoURL: json['photoURL'] as String?,
      adminIds: Parser.parseStringList(json['adminIds']),
      memberIds: Parser.parseStringList(json['memberIds']),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null ? Parser.parseTimestamp(json['lastMessageAt']) : null,
      unreadCount: json['unreadCount'] != null ? Map<String, int>.from(json['unreadCount']) : {},
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
    );
  }

  factory GroupModel.fromEntity(GroupEntity entity) => GroupModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    photoURL: entity.photoURL,
    adminIds: entity.adminIds,
    memberIds: entity.memberIds,
    lastMessage: entity.lastMessage,
    lastMessageAt: entity.lastMessageAt != null ? Timestamp.fromDate(entity.lastMessageAt!) : null,
    unreadCount: entity.unreadCount,
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
  );

  factory GroupModel.empty() => GroupModel(
    id: '',
    name: '',
    adminIds: [],
    memberIds: [],
    unreadCount: {},
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'photoURL': photoURL,
    'adminIds': adminIds,
    'memberIds': memberIds,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt,
    'unreadCount': unreadCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  GroupEntity toEntity() => GroupEntity(
    id: id,
    name: name,
    description: description,
    photoURL: photoURL,
    adminIds: adminIds,
    memberIds: memberIds,
    lastMessage: lastMessage,
    lastMessageAt: lastMessageAt?.toDate(),
    unreadCount: unreadCount,
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
  );

  static List<GroupModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => GroupModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
}
