import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/application/notifiers/otp_notifier.dart';

/// Dialog xác thực Email OTP gồm 2 giai đoạn:
/// 1. Gửi mã → Hiển thị email đã che + nút "Gửi mã"
/// 2. Nhập mã → Input 6 số + đếm ngược cho phép gửi lại
///
/// Trả về `true` nếu OTP xác minh thành công.
class EmailOtpDialog extends ConsumerStatefulWidget {
  final String purpose;
  final String purposeLabel; // VD: "đổi mật khẩu"
  final String actionTitle; // VD: "Đổi mật khẩu"

  const EmailOtpDialog({
    super.key,
    required this.purpose,
    required this.purposeLabel,
    required this.actionTitle,
  });

  @override
  ConsumerState<EmailOtpDialog> createState() => _EmailOtpDialogState();
}

class _EmailOtpDialogState extends ConsumerState<EmailOtpDialog> {
  final List<TextEditingController> _boxControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _countdownTimer;
  int _secondsLeft = 0;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    // Tự động gửi OTP khi mở dialog
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _boxControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Gửi OTP ──────────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    await ref
        .read(otpNotifierProvider.notifier)
        .sendOtp(purpose: widget.purpose, purposeLabel: widget.purposeLabel);

    if (!mounted) return;

    final state = ref.read(otpNotifierProvider);
    if (state is OtpSent) {
      setState(() => _codeSent = true);
      _startCountdown(60);
    }
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    if (mounted) setState(() => _secondsLeft = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _verify() async {
    final code = _boxControllers.map((c) => c.text).join();
    if (code.length != 6) return;

    final success = await ref
        .read(otpNotifierProvider.notifier)
        .verifyOtp(code: code, purpose: widget.purpose);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  void _onBoxChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final full = _boxControllers.map((c) => c.text).join();
    if (full.length == 6) _verify();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpNotifierProvider);
    final isLoading = otpState is OtpLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    color: AppColors.darkAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.actionTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Xác thực qua email',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Trạng thái gửi / chờ ─────────────────────────────────
            if (!_codeSent || isLoading) ...[
              _buildSendingState(isLoading),
            ] else ...[
              _buildInputState(otpState),
            ],
          ],
        ),
      ),
    );
  }

  // ── Giao diện khi đang gửi hoặc chưa gửi ─────────────────────────────────────
  Widget _buildSendingState(bool isLoading) {
    final state = ref.watch(otpNotifierProvider);
    final isError = state is OtpError;

    if (isError) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.message,
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sendOtp,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'Đang gửi mã xác thực...',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Giao diện nhập OTP ────────────────────────────────────────────────────────
  Widget _buildInputState(OtpState otpState) {
    final maskedEmail = otpState is OtpSent ? otpState.maskedEmail : '';
    final errorMsg = otpState is OtpError ? otpState.message : null;
    final isLoading = otpState is OtpLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkAccent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.darkAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Mã OTP đã được gửi đến ',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: maskedEmail,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkAccent,
                        ),
                      ),
                      const TextSpan(text: '. Có hiệu lực trong 5 phút.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Label
        const Text(
          'Nhập mã 6 chữ số',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // 6 ô OTP riêng biệt
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i, isLoading)),
        ),

        // Error
        if (errorMsg != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMsg,
                    style: TextStyle(color: AppColors.error, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Gửi lại + countdown
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Không nhận được mã? ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            _secondsLeft > 0
                ? Text(
                    'Gửi lại sau ${_secondsLeft}s',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  )
                : GestureDetector(
                    onTap: isLoading ? null : _sendOtp,
                    child: Text(
                      'Gửi lại',
                      style: TextStyle(
                        color: AppColors.darkAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 20),

        // Nút xác nhận
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : _verify,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkAccent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Một ô nhập OTP ────────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index, bool disabled) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextFormField(
        controller: _boxControllers[index],
        focusNode: _focusNodes[index],
        enabled: !disabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.darkAccent, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (val) => _onBoxChanged(index, val),
        // Xử lý phím backspace để quay về ô trước
        onEditingComplete: () {},
      ),
    );
  }
}
