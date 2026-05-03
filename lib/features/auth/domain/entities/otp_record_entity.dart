class OtpRecordEntity {
  final String code;
  final DateTime expiresAt;
  final String purpose;
  final int attempts;

  const OtpRecordEntity({
    required this.code,
    required this.expiresAt,
    required this.purpose,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isBlocked => attempts >= 5;
}
