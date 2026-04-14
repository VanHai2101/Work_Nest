class MessageEntity {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final List<String> attachments;
  final List<String> readBy;
  final String type;
  final DateTime? deletedAt;

  MessageEntity({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.attachments = const [],
    this.readBy = const [],
    this.type = 'text',
    this.deletedAt,
  });
}
