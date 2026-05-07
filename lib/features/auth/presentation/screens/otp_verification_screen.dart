import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/domain/states/operation_state.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/send_email_otp.dart';
import '../../domain/usecases/verify_email_otp.dart';
import '../providers/index.dart';

/// Màn hình nhập mã OTP 6 số được gửi tới email
class OTPVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String fullName;
  final String password;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.fullName,
    required this.password,
  });

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isSending = false;
  String? _errorMessage;

  // Countdown gửi lại mã
  int _resendCountdown = 60;
  Timer? _timer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() => _errorMessage = null);

    // Auto-verify khi điền đủ 6 số
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Bước 1: Xác minh OTP
    final verifyUseCase = ref.read(verifyEmailOTPUseCaseProvider);
    final verifyResult = await verifyUseCase.call(
      VerifyEmailOTPParams(email: widget.email, otp: otp),
    );

    await verifyResult.fold(
      (failure) async {
        final msg = (failure is OperationFailure)
            ? failure.errorMessage
            : failure.message ?? 'Mã OTP không đúng';
        setState(() {
          _errorMessage = msg;
          _isVerifying = false;
        });
        _shakeController.reset();
        _shakeController.forward();
        for (var c in _controllers) {
          c.clear();
        }
        _focusNodes[0].requestFocus();
      },
      (_) async {
        // Bước 2: OTP đúng → Thực hiện đăng ký tài khoản
        final signUpUseCase = ref.read(signUpUseCaseProvider);
        final signUpResult = await signUpUseCase.call(
          SignUpParams(
            email: widget.email,
            password: widget.password,
            fullName: widget.fullName,
          ),
        );

        signUpResult.fold(
          (failure) {
            final msg = (failure is OperationFailure)
                ? failure.errorMessage
                : failure.message ?? 'Đăng ký thất bại';
            setState(() {
              _errorMessage = msg;
              _isVerifying = false;
            });
          },
          (_) {
            if (mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home', (route) => false);
            }
          },
        );
      },
    );
  }

  Future<void> _resendOTP() async {
    if (_resendCountdown > 0) return;
    setState(() => _isSending = true);

    final useCase = ref.read(sendEmailOTPUseCaseProvider);
    final result = await useCase.call(SendEmailOTPParams(email: widget.email));

    result.fold(
      (failure) {
        final msg = (failure is OperationFailure)
            ? failure.errorMessage
            : failure.message ?? 'Gửi lại thất bại';
        setState(() {
          _errorMessage = msg;
          _isSending = false;
        });
      },
      (_) {
        setState(() => _isSending = false);
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã gửi lại mã OTP!'),
            backgroundColor: AppColors.darkSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppLayout.paddingLarge,
          child: Column(
            children: [
              AppLayout.gapLarge,

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_rounded,
                  size: 44,
                  color: AppColors.accent,
                ),
              ),
              AppLayout.gapLarge,

              // Title
              Text(
                'Xác thực Email',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              AppLayout.gapSmall,

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: 'Chúng tôi đã gửi mã 6 số đến\n'),
                    TextSpan(
                      text: widget.email,
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const TextSpan(text: '\nMã có hiệu lực trong 5 phút.'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final direction =
                      _shakeController.status == AnimationStatus.reverse
                          ? -1.0
                          : 1.0;
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * direction, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _buildOTPBox(i)),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                AppLayout.gapMedium,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.medium,
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              AppLayout.gapLarge,

              // Resend button
              _isSending
                  ? CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2,
                    )
                  : TextButton(
                      onPressed: _resendCountdown > 0 ? null : _resendOTP,
                      child: Text(
                        _resendCountdown > 0
                            ? 'Gửi lại mã sau $_resendCountdown giây'
                            : 'Gửi lại mã OTP',
                        style: TextStyle(
                          color: _resendCountdown > 0
                              ? AppColors.textTertiary
                              : AppColors.info,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasError = _errorMessage != null;
    final hasValue = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFocused
              ? AppColors.accent
              : hasError
                  ? AppColors.error
                  : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Center(
        child: TextSelectionTheme(
          data: const TextSelectionThemeData(
            selectionColor: Colors.transparent,
            cursorColor: Colors.transparent,
            selectionHandleColor: Colors.transparent,
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            showCursor: false,
            cursorColor: Colors.transparent,
            cursorWidth: 0,
            cursorHeight: 0,
            enableInteractiveSelection: false,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              isCollapsed: true,
            ),
            onChanged: (v) => _onDigitChanged(v, index),
          ),
        ),
      ),
    );
  }
}
