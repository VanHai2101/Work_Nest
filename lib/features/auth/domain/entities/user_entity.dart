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
  final bool isOnline;
  final bool isEmailMfaEnabled;
  final DateTime? lastSeen;

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
    this.isOnline = false,
    this.isEmailMfaEnabled = false,
    this.lastSeen,
  });

  bool get isPro => plan == 'pro' || plan == 'business';
  bool get isBusiness => plan == 'business';
  bool get isPremium => isPro || isBusiness;
  bool get isFree => plan == 'free';
}
