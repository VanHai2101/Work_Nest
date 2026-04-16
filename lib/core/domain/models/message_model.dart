class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoURL;
  final String text;
  final DateTime sentAt;
  final List<String>? readBy;
  final String? type; // 'text', 'image', 'file', 'video'
  final List<String>? attachments;
  final DateTime? deletedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoURL,
    required this.text,
    required this.sentAt,
    this.readBy,
    this.type = 'text',
    this.attachments,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      senderPhotoURL: map['senderPhotoURL'],
      text: map['text'] ?? '',
      sentAt: map['sentAt']?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? []),
      type: map['type'] ?? 'text',
      attachments: List<String>.from(map['attachments'] ?? []),
      deletedAt: map['deletedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'text': text,
      'sentAt': sentAt,
      'readBy': readBy ?? [],
      'type': type,
      'attachments': attachments,
      'deletedAt': deletedAt,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderPhotoURL,
    String? text,
    DateTime? sentAt,
    List<String>? readBy,
    String? type,
    List<String>? attachments,
    DateTime? deletedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoURL: senderPhotoURL ?? this.senderPhotoURL,
      text: text ?? this.text,
      sentAt: sentAt ?? this.sentAt,
      readBy: readBy ?? this.readBy,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
