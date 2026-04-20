import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId; // Optional UID to view another user's profile

  const ProfileScreen({this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nếu không có userId truyền vào, mặc định là user hiện tại
    final isOwnProfile =
        userId == null || userId == FirebaseAuth.instance.currentUser?.uid;

    final profileAsync = isOwnProfile
        ? ref.watch(userProfileProvider)
        : ref.watch(userProfileByIdProvider(userId!));

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          isOwnProfile ? AppStrings.profile : 'Hồ sơ người dùng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, stack) =>
            Center(child: Text('${AppErrors.genericError}: $err')),
        data: (user) {
          if (user == null) {
            return Center(child: Text(AppErrors.genericError));
          }

          return SingleChildScrollView(
            padding: AppLayout.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                AppAvatar(id: user.uid, photoURL: user.photoURL, size: 100),
                AppLayout.gapMedium,
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppLayout.gapSmall,
                Text(
                  user.email,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                AppLayout.gapXLarge,
                _buildInfoCard(
                  icon: Icons.star_rounded,
                  title: 'Gói hiện tại',
                  value: user.plan.toUpperCase(),
                  subtitle: user.planExpiresAt != null
                      ? 'Hết hạn: ${_formatDate(user.planExpiresAt!)}'
                      : 'Miễn phí vĩnh viễn',
                ),
                AppLayout.gapMedium,
                _buildInfoCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'Thành viên từ',
                  value: _formatDate(user.createdAt),
                ),

                if (isOwnProfile) ...[
                  AppLayout.gapXLarge,
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.upgrade_rounded),
                      label: const Text('Nâng cấp gói'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng nâng cấp đang phát triển'),
                          ),
                        );
                      },
                    ),
                  ),
                  AppLayout.gapSmall,

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: AppColors.textPrimary,
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Cài đặt'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cài đặt đang phát triển'),
                          ),
                        );
                      },
                    ),
                  ),
                  AppLayout.gapSmall,

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Đăng xuất'),
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ),
                ] else ...[
                  AppLayout.gapXLarge,
                  // Nếu không phải profile của mình, có thể thêm nút Tin nhắn hoặc Kết bạn
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Gửi tin nhắn'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng nhắn tin đang phát triển'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: AppLayout.paddingMedium,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentDark, size: AppSize.iconMedium),
          AppLayout.horizontalGapMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
                AppLayout.gapSmall,
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  AppLayout.gapSmall,
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
