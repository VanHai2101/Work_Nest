class Group {
  final String id;
  final String name;
  final String? description;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? photoURL;
  final String lastMessage;
  final DateTime lastMessageAt;
  final Map<String, int> unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.adminIds,
    required this.memberIds,
    this.photoURL,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory Group.fromMap(Map<String, dynamic> map, String id) {
    return Group(
      id: id,
      name: map['name'] ?? '',
      description: map['description'],
      adminIds: List<String>.from(map['adminIds'] ?? []),
      memberIds: List<String>.from(map['memberIds'] ?? []),
      photoURL: map['photoURL'],
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt']?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'photoURL': photoURL,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'unreadCount': unreadCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? adminIds,
    List<String>? memberIds,
    String? photoURL,
    String? lastMessage,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      photoURL: photoURL ?? this.photoURL,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
