class ChatEntity {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatEntity({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });
}
