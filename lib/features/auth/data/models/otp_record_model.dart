import '../../domain/entities/otp_record_entity.dart';

class OtpRecordModel extends OtpRecordEntity {
  const OtpRecordModel({
    required super.code,
    required super.expiresAt,
    required super.purpose,
    super.attempts,
  });

  Map<String, dynamic> toMap() => {
    'code': code,
    'expiresAt': expiresAt.toIso8601String(),
    'purpose': purpose,
    'attempts': attempts,
  };

  factory OtpRecordModel.fromMap(Map<String, dynamic> map) => OtpRecordModel(
    code: map['code'] as String,
    expiresAt: DateTime.parse(map['expiresAt'] as String),
    purpose: map['purpose'] as String,
    attempts: (map['attempts'] as int?) ?? 0,
  );

  factory OtpRecordModel.fromEntity(OtpRecordEntity entity) => OtpRecordModel(
    code: entity.code,
    expiresAt: entity.expiresAt,
    purpose: entity.purpose,
    attempts: entity.attempts,
  );
}
