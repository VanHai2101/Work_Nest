// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/domain/states/index.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/application/notifiers/totp_notifier.dart';
import '../../../auth/domain/entities/totp_secret_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class TotpSetupScreen extends ConsumerStatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  ConsumerState<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends ConsumerState<TotpSetupScreen> {
  TotpSecretEntity? _secret;
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1; // 1: QR Code, 2: Verification

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _fetchSecret);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _fetchSecret() async {
    final secret = await ref
        .read(totpNotifierProvider.notifier)
        .beginEnrollment();
    if (mounted && secret != null) {
      setState(() => _secret = secret);
    }
  }

  Future<void> _onVerify() async {
    if (_secret == null) return;
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(totpNotifierProvider.notifier)
        .verifyAndActivate(_secret!, _otpController.text.trim());

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bật xác thực 2 yếu tố thành công!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(totpNotifierProvider);
    final isLoading = state is OperationLoading;
    final errorMsg = state is OperationFailure ? state.message : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thiết lập 2FA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: buildContent(context, isLoading, errorMsg),
    );
  }
}

extension on _TotpSetupScreenState {
  Widget buildContent(BuildContext context, bool isLoading, String? errorMsg) {
    if (_secret == null && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_secret == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text('Không thể tải mã QR'),
            TextButton(onPressed: _fetchSecret, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stepper Indicator Simple
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(1, active: _currentStep >= 1),
              _buildStepDivider(active: _currentStep >= 2),
              _buildStepIndicator(2, active: _currentStep >= 2),
            ],
          ),
          const SizedBox(height: 32),

          if (_currentStep == 1)
            _buildStep1()
          else
            _buildStep2(isLoading, errorMsg),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, {bool active = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.darkAccent : AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: active ? Colors.white : AppColors.textTertiary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepDivider({bool active = false}) {
    return Container(
      width: 40,
      height: 2,
      color: active ? AppColors.darkAccent : AppColors.surfaceVariant,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Text(
          'Quét mã QR',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Sử dụng Google Authenticator hoặc ứng dụng xác thực khác để quét mã bên dưới.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: QrImageView(
            data: _secret!.qrCodeUrl,
            version: QrVersions.auto,
            size: 200.0,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.textPrimary,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Copy Key fallback
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _secret!.secretKey));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã sao chép khóa bí mật')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.vpn_key_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _secret!.secretKey,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy_rounded, size: 14, color: AppColors.darkAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() => _currentStep = 2),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Tôi đã quét mã',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(bool isLoading, String? errorMsg) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Nhập mã xác thực',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhập mã 6 chữ số từ ứng dụng xác thực của bạn để hoàn tất thiết lập.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.darkAccent, width: 2),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              if (v == null || v.length < 6) return 'Nhập đủ 6 số';
              return null;
            },
          ),
          if (errorMsg != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMsg,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => setState(() => _currentStep = 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Quay lại'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: isLoading ? null : _onVerify,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                          'Xác minh',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
