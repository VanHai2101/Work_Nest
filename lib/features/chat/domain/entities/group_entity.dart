class GroupEntity {
  final String id;
  final String name;
  final String? description;
  final String? photoURL;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupEntity({
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
}
