import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/chat_entity.dart';
import 'package:work_nest/core/utils/parser.dart';

class ChatModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final Timestamp? lastMessageAt;
  final Map<String, int> unreadCount;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  ChatModel({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return ChatModel.empty();
    return ChatModel(
      id: id ?? '',
      participantIds: Parser.parseStringList(json['participantIds']),
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null ? Parser.parseTimestamp(json['lastMessageAt']) : null,
      unreadCount: json['unreadCount'] != null ? Map<String, int>.from(json['unreadCount']) : {},
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
    );
  }

  factory ChatModel.fromEntity(ChatEntity entity) => ChatModel(
    id: entity.id,
    participantIds: entity.participantIds,
    lastMessage: entity.lastMessage,
    lastMessageAt: entity.lastMessageAt != null ? Timestamp.fromDate(entity.lastMessageAt!) : null,
    unreadCount: entity.unreadCount,
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
  );

  factory ChatModel.empty() => ChatModel(
    id: '',
    participantIds: [],
    unreadCount: {},
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'participantIds': participantIds,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt,
    'unreadCount': unreadCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  ChatEntity toEntity() => ChatEntity(
    id: id,
    participantIds: participantIds,
    lastMessage: lastMessage,
    lastMessageAt: lastMessageAt?.toDate(),
    unreadCount: unreadCount,
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
  );

  static List<ChatModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => ChatModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
}
