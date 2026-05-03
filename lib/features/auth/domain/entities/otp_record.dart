/// Model lưu vào Firestore collection `otp_verifications/{userId}`
class OtpRecord {
  final String code;
  final DateTime expiresAt;
  final String purpose; // 'change_password' | 'delete_account'
  final int attempts;   // Đếm số lần nhập sai để chặn brute force

  const OtpRecord({
    required this.code,
    required this.expiresAt,
    required this.purpose,
    this.attempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isBlocked => attempts >= 5; // Khóa sau 5 lần sai

  Map<String, dynamic> toMap() => {
        'code': code,
        'expiresAt': expiresAt.toIso8601String(),
        'purpose': purpose,
        'attempts': attempts,
      };

  factory OtpRecord.fromMap(Map<String, dynamic> map) => OtpRecord(
        code: map['code'] as String,
        expiresAt: DateTime.parse(map['expiresAt'] as String),
        purpose: map['purpose'] as String,
        attempts: (map['attempts'] as int?) ?? 0,
      );
}
