import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/utils/index.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final Timestamp sentAt;
  final List<String> attachments;
  final List<String> readBy;
  final String type;
  final Timestamp? deletedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.attachments = const [],
    this.readBy = const [],
    this.type = 'text',
    this.deletedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return MessageModel.empty();
    return MessageModel(
      id: id ?? '',
      senderId: json['senderId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      sentAt: Parser.parseTimestamp(json['sentAt']),
      attachments: Parser.parseStringList(json['attachments']),
      readBy: Parser.parseStringList(json['readBy']),
      type: json['type'] as String? ?? 'text',
      deletedAt: json['deletedAt'] != null ? Parser.parseTimestamp(json['deletedAt']) : null,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) => MessageModel(
    id: entity.id,
    senderId: entity.senderId,
    text: entity.text,
    sentAt: Timestamp.fromDate(entity.sentAt),
    attachments: entity.attachments,
    readBy: entity.readBy,
    type: entity.type,
    deletedAt: entity.deletedAt != null ? Timestamp.fromDate(entity.deletedAt!) : null,
  );

  factory MessageModel.empty() => MessageModel(
    id: '',
    senderId: '',
    text: '',
    sentAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'text': text,
    'sentAt': sentAt,
    'attachments': attachments,
    'readBy': readBy,
    'type': type,
    'deletedAt': deletedAt,
  };

  MessageEntity toEntity() => MessageEntity(
    id: id,
    senderId: senderId,
    text: text,
    sentAt: sentAt.toDate(),
    attachments: attachments,
    readBy: readBy,
    type: type,
    deletedAt: deletedAt?.toDate(),
  );

  static List<MessageModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
}
