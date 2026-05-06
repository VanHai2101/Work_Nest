import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dữ liệu OTP nhận được từ Deep Link
class IncomingOtp {
  final String code;
  final String purpose;

  IncomingOtp({required this.code, required this.purpose});
}

/// Provider lưu trữ OTP nhận được từ bên ngoài (Deep Link)
/// Khi nhận được dữ liệu, các màn hình/dialog liên quan sẽ lắng nghe và tự động xử lý.
final incomingOtpProvider = StateProvider<IncomingOtp?>((ref) => null);
