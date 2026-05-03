import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/states/index.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/application/notifiers/auth_notifier.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/email_otp_dialog.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserState = ref.watch(currentUserProvider);
    final currentUser = currentUserState.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bảo mật',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSecurityOption(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Thay đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn định kỳ',
            onTap: () => _onChangePassword(context, ref),
          ),
          _buildSecurityOption(
            context,
            icon: Icons.phonelink_lock_rounded,
            title: 'Xác thực 2 yếu tố (2FA)',
            subtitle: currentUser?.isEmailMfaEnabled == true
                ? 'Tính năng bảo vệ đang BẬT'
                : 'Thêm lớp bảo vệ cho tài khoản',
            badge: currentUser?.isEmailMfaEnabled == true ? 'Đã bật' : null,
            onTap: () => _onToggle2FA(context, ref, currentUser?.isEmailMfaEnabled ?? false),
          ),
          _buildSecurityOption(
            context,
            icon: Icons.devices_rounded,
            title: 'Các thiết bị đã đăng nhập',
            subtitle: 'Quản lý phiên đăng nhập của bạn',
            badge: 'Sắp ra mắt',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 32),
          Text(
            'HÀNH ĐỘNG NGUY HIỂM',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildSecurityOption(
            context,
            icon: Icons.delete_forever_rounded,
            title: 'Xóa tài khoản',
            subtitle: 'Vĩnh viễn xóa dữ liệu của bạn',
            color: AppColors.error,
            onTap: () => _onDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  // ─── Bật/Tắt 2FA: Xác thực OTP -> Cập nhật Firestore ─────────────────────
  Future<void> _onToggle2FA(BuildContext context, WidgetRef ref, bool currentStatus) async {
    final actionName = currentStatus ? 'tắt' : 'bật';
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EmailOtpDialog(
        purpose: 'toggle_2fa',
        purposeLabel: '$actionName 2FA',
        actionTitle: '${currentStatus ? 'Tắt' : 'Bật'} xác thực 2 lớp',
      ),
    );

    if (verified == true && context.mounted) {
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;

      try {
        await ref.read(userRepositoryProvider).updateMfaStatus(user.uid, !currentStatus);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã ${currentStatus ? 'tắt' : 'bật'} xác thực 2 lớp thành công!'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Có lỗi xảy ra. Vui lòng thử lại sau.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  // ─── Đổi mật khẩu: xác thực OTP trước rồi mới vào màn hình đổi pass ─────────
  Future<void> _onChangePassword(BuildContext context, WidgetRef ref) async {
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmailOtpDialog(
        purpose: 'change_password',
        purposeLabel: 'đổi mật khẩu',
        actionTitle: 'Đổi mật khẩu',
      ),
    );

    if (verified == true && context.mounted) {
      // OTP đã xác minh → vào màn hình đổi mật khẩu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChangePasswordScreenNoReauth(),
        ),
      );
    }
  }

  // ─── Xóa tài khoản: xác thực OTP → dialog xác nhận "XÓA" ───────────────────
  Future<void> _onDeleteAccount(BuildContext context, WidgetRef ref) async {
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const EmailOtpDialog(
        purpose: 'delete_account',
        purposeLabel: 'xóa tài khoản',
        actionTitle: 'Xóa tài khoản',
      ),
    );

    if (verified != true || !context.mounted) return;

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DeleteAccountConfirmDialog(),
    );

    if (deleted == true && context.mounted) {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tính năng này đang được phát triển'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSecurityOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? color,
  }) {
    final iconColor = color ?? AppColors.darkAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.darkAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: TextStyle(
                        color: AppColors.darkAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
        subtitle: Text(subtitle,
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.black12, size: 14),
      ),
    );
  }
}

// ── ChangePasswordScreenNoReauth ──────────────────────────────────────────────
class ChangePasswordScreenNoReauth extends ConsumerStatefulWidget {
  const ChangePasswordScreenNoReauth({super.key});

  @override
  ConsumerState<ChangePasswordScreenNoReauth> createState() =>
      _ChangePasswordScreenNoReauthState();
}

class _ChangePasswordScreenNoReauthState
    extends ConsumerState<ChangePasswordScreenNoReauth> {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureNew = true, _obscureConfirm = true;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .changePassword(_newPassCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      if (next is OperationSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Đổi mật khẩu thành công!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    });

    final state = ref.watch(authNotifierProvider);
    final isLoading = state is OperationLoading;
    final error = state is OperationFailure ? state.message : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mật khẩu mới',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email đã xác thực. Nhập mật khẩu mới của bạn.',
                        style: TextStyle(
                            color: Colors.green.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Mật khẩu mới',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                enabled: !isLoading,
                decoration: _inputDeco(
                  hint: 'Tối thiểu 6 ký tự',
                  icon: Icons.lock_outline_rounded,
                  suffix: IconButton(
                    icon: Icon(_obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined, size: 20),
                    onPressed: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                  if (v.length < 6) return 'Tối thiểu 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Xác nhận mật khẩu',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                enabled: !isLoading,
                decoration: _inputDeco(
                  hint: 'Nhập lại mật khẩu mới',
                  icon: Icons.lock_reset_rounded,
                  suffix: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v != _newPassCtrl.text) return 'Mật khẩu không khớp';
                  return null;
                },
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(error,
                      style:
                          TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Lưu mật khẩu mới',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
      {required String hint,
      required IconData icon,
      Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppColors.darkAccent, width: 1.5)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

// ── DeleteAccountConfirmDialog ────────────────────────────────────────────────
class DeleteAccountConfirmDialog extends StatefulWidget {
  const DeleteAccountConfirmDialog({super.key});

  @override
  State<DeleteAccountConfirmDialog> createState() =>
      _DeleteAccountConfirmDialogState();
}

class _DeleteAccountConfirmDialogState
    extends State<DeleteAccountConfirmDialog> {
  final _ctrl = TextEditingController();
  bool _canDelete = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.delete_forever_rounded,
                  color: AppColors.error, size: 24),
              const SizedBox(width: 10),
              Text('Xác nhận xóa tài khoản',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.error)),
            ]),
            const SizedBox(height: 16),
            Text('Nhập "XÓA" để xác nhận',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              onChanged: (v) =>
                  setState(() => _canDelete = v.trim() == 'XÓA'),
              decoration: InputDecoration(
                hintText: 'XÓA',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.error, width: 1.5)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed:
                      _canDelete ? () => Navigator.of(context).pop(true) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    disabledBackgroundColor:
                        AppColors.error.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Xóa tài khoản',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
