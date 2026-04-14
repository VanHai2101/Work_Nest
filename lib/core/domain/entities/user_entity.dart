class UserEntity {
  final String id;
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String plan;
  final List<String> fcmTokens;
  final DateTime? planExpiresAt;
  final DateTime? planUpdatedAt;

  UserEntity({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    this.plan = 'free',
    this.fcmTokens = const [],
    this.planExpiresAt,
    this.planUpdatedAt,
  });
}
