import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/states/index.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/presentation/providers/index.dart';
import 'reauthenticate_dialog.dart';

/// Dialog xác nhận xóa tài khoản gồm 2 bước:
/// 1. Hiển thị cảnh báo, yêu cầu người dùng nhập "XÓA" để xác nhận.
/// 2. Mở ReauthenticateDialog để xác thực lại.
/// 3. Thực hiện xóa tài khoản.
///
/// Trả về `true` nếu xóa thành công.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  final String userEmail;

  const DeleteAccountDialog({super.key, required this.userEmail});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _confirmCtrl = TextEditingController();
  bool _canDelete = false;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onConfirmDelete() async {
    // Bước 1: Yêu cầu xác thực lại
    final reauthed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReauthenticateDialog(
        email: widget.userEmail,
        actionLabel: 'xóa tài khoản',
      ),
    );

    if (reauthed != true || !mounted) return;

    // Bước 2: Thực hiện xóa
    await ref.read(authNotifierProvider.notifier).deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe kết quả
    ref.listen<OperationState>(authNotifierProvider, (_, next) {
      if (!mounted) return;
      if (next is OperationSuccess) {
        // Đóng dialog và báo thành công cho màn hình cha
        Navigator.of(context).pop(true);
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is OperationLoading;
    final errorMsg = authState is OperationFailure ? (authState).message : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header cảnh báo ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xóa tài khoản',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.error,
                          ),
                        ),
                        Text(
                          'Hành động này không thể hoàn tác',
                          style: TextStyle(
                            color: AppColors.error.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Cảnh báo nội dung bị xóa ──────────────────────────
            _WarningItem(
              icon: Icons.person_off_outlined,
              text: 'Tài khoản của bạn sẽ bị xóa vĩnh viễn',
            ),
            _WarningItem(
              icon: Icons.storage_outlined,
              text: 'Toàn bộ dữ liệu cá nhân sẽ bị xóa',
            ),
            _WarningItem(
              icon: Icons.history_toggle_off_outlined,
              text: 'Không thể khôi phục sau khi xóa',
            ),

            const SizedBox(height: 16),

            // ── Ô xác nhận nhập "XÓA" ─────────────────────────────
            Text(
              'Nhập "XÓA" để xác nhận',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmCtrl,
              enabled: !isLoading,
              onChanged: (v) {
                setState(() => _canDelete = v.trim() == 'XÓA');
              },
              decoration: InputDecoration(
                hintText: 'Nhập XÓA',
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
                  borderSide: BorderSide(color: AppColors.error, width: 1.5),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),

            // ── Error message ────────────────────────────────────────
            if (errorMsg != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 15,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        errorMsg,
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Buttons ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: AppColors.border),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: (_canDelete && !isLoading)
                        ? _onConfirmDelete
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      disabledBackgroundColor: AppColors.error.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xóa tài khoản',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _WarningItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
