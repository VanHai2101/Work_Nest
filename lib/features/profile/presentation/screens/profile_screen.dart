import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../../../core/constants/index.dart';
import '../../../notifications/presentation/screens/index.dart';
import '../../../projects/presentation/providers/index.dart';
import '../../../tasks/presentation/providers/index.dart';
import '../../../chat/presentation/providers/index.dart';
import '../../../notifications/presentation/providers/index.dart';
import '../../../auth/presentation/providers/index.dart';
import 'index.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;
  const ProfileScreen({this.userId, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final targetUserId = userId ?? currentUserId ?? '';
    final isOwnProfile = targetUserId == currentUserId;

    final profileAsync = ref.watch(userProfileByIdProvider(targetUserId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isOwnProfile ? 'Cài đặt tài khoản' : 'Hồ sơ',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: profileAsync.when(
        data: (user) {
          if (user == null)
            // ignore: curly_braces_in_flow_control_structures
            return const Center(child: Text('Không tìm thấy người dùng'));

          // Watch Live Statistics
          final projectsCount =
              ref.watch(userProjectsProvider(user.uid)).value?.length ?? 0;
          final tasksCount =
              ref.watch(userAssignedTasksProvider(user.uid)).value?.length ?? 0;
          final groupsCount =
              ref.watch(userGroupsProvider(user.uid)).value?.length ?? 0;
          final unreadNotifs =
              ref.watch(unreadNotificationsCountProvider).value ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),
                _buildStatsSection(projectsCount, tasksCount, groupsCount),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionTitle('TRẢI NGHIỆM'),
                      _NavItem(
                        icon: Icons.notifications_rounded,
                        label: 'Thông báo',
                        color: AppColors.darkWarning,
                        badge: unreadNotifs > 0
                            ? unreadNotifs.toString()
                            : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                      ),
                      _NavItem(
                        icon: Icons.security_rounded,
                        label: 'Bảo mật',
                        color: AppColors.darkSuccess,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SecurityScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('ỨỨNG DỤNG'),
                      _NavItem(
                        icon: Icons.help_center_rounded,
                        label: 'Trung tâm trợ giúp',
                        color: AppColors.darkAccent,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HelpCenterScreen(),
                          ),
                        ),
                      ),
                      _NavItem(
                        icon: Icons.info_rounded,
                        label: 'Về WorkNest',
                        color: AppColors.darkTextSecondary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    final userName = user.displayName;
    final userEmail = user.email;
    final userInitial = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : 'U';
    final plan = user.plan.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(
                id: userName,
                userId: user.uid,
                photoURL: user.photoURL,
                size: 100,
                showOnline: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkAccent.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.darkAccent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'TÀI KHOẢN $plan',

                  style: const TextStyle(
                    color: AppColors.darkAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int projs, int tasks, int groups) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        children: [
          _StatItem(number: projs.toString(), label: 'Dự án'),
          _StatDivider(),
          _StatItem(number: tasks.toString(), label: 'Nhiệm vụ'),
          _StatDivider(),
          _StatItem(number: groups.toString(), label: 'Nhóm'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.error.withOpacity(0.2)),
          ),
          foregroundColor: AppColors.error,
          backgroundColor: AppColors.error.withOpacity(0.04),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              'Đăng xuất khỏi thiết bị',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: AppColors.border);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black26,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
