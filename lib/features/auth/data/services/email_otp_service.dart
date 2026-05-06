import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/otp_record.dart';

class EmailJsConfig {
  static const serviceId = 'HoangHai@240104';
  static const templateId = 'template_wrbe2qw';
  static const publicKey = 'UTmlWutX4mgZAYIiw';
}

class EmailOtpService {
  final FirebaseFirestore _firestore;
  static const _collection = 'otp_verifications';
  static const _otpTtlMinutes = 5;

  EmailOtpService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String _generateCode() {
    final rng = Random.secure();
    return (100000 + rng.nextInt(900000)).toString();
  }

  Future<String> createAndSaveOtp({
    required String userId,
    required String email,
    required String purpose,
  }) async {
    final code = _generateCode();
    final record = OtpRecord(
      code: code,
      expiresAt: DateTime.now().add(const Duration(minutes: _otpTtlMinutes)),
      purpose: purpose,
    );

    try {
      await _firestore.collection(_collection).doc(userId).set(record.toMap());
      debugPrint('OTP saved successfully to Firestore');
    } catch (e) {
      debugPrint('Firestore Error saving OTP: $e');
      rethrow;
    }

    return code;
  }

  Future<void> sendOtpEmail({
    required String toEmail,
    required String displayName,
    required String otpCode,
    required String purposeLabel,
  }) async {
    const url = 'https://api.emailjs.com/api/v1.0/email/send';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': EmailJsConfig.serviceId,
          'template_id': EmailJsConfig.templateId,
          'user_id': EmailJsConfig.publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': displayName,
            'otp_code': otpCode,
            'purpose': purposeLabel,
            'expiry_minutes': _otpTtlMinutes.toString(),
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('EmailJS Error Status: ${response.statusCode}');
        debugPrint('EmailJS Error Body: ${response.body}');
        throw Exception('Không thể gửi email. Lỗi: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error in sendOtpEmail: $e');
      rethrow;
    }
  }

  Future<bool> verifyOtp({
    required String userId,
    required String inputCode,
    required String purpose,
  }) async {
    final doc = await _firestore.collection(_collection).doc(userId).get();

    if (!doc.exists) throw OtpNotFoundException();

    final record = OtpRecord.fromMap(doc.data()!);

    if (record.purpose != purpose) throw OtpNotFoundException();

    if (record.isBlocked) throw OtpBlockedException();

    if (record.isExpired) {
      await _firestore.collection(_collection).doc(userId).delete();
      throw OtpExpiredException();
    }

    if (record.code != inputCode.trim()) {
      await _firestore.collection(_collection).doc(userId).update({
        'attempts': record.attempts + 1,
      });
      final remaining = (5 - (record.attempts + 1)).toInt();
      throw OtpWrongException(remainingAttempts: remaining);
    }

    await _firestore.collection(_collection).doc(userId).delete();
    return true;
  }

  Future<void> clearOtp(String userId) async {
    await _firestore.collection(_collection).doc(userId).delete();
  }
}

class OtpNotFoundException implements Exception {
  final String message = 'Không tìm thấy mã OTP. Vui lòng gửi lại.';
  @override
  String toString() => message;
}

class OtpExpiredException implements Exception {
  final String message = 'Mã OTP đã hết hạn. Vui lòng gửi lại.';
  @override
  String toString() => message;
}

class OtpBlockedException implements Exception {
  final String message =
      'Tài khoản bị khóa tạm thời do nhập sai quá nhiều lần. Vui lòng gửi lại mã mới.';
  @override
  String toString() => message;
}

class OtpWrongException implements Exception {
  final int remainingAttempts;
  OtpWrongException({required this.remainingAttempts});
  String get message => remainingAttempts > 0
      ? 'Mã OTP không đúng. Còn $remainingAttempts lần thử.'
      : 'Mã OTP không đúng. Tài khoản sẽ bị khóa nếu nhập sai thêm.';
  @override
  String toString() => message;
}
