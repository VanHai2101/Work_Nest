import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

/// Profile menu drawer widget (Premium Redesign - Fully Dynamic)
class ProfileMenuDrawer extends ConsumerWidget {
  final VoidCallback onLogout;

  const ProfileMenuDrawer({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Drawer(
      width: 300,
      backgroundColor: AppColors.darkBg,
      child: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final userName = user.displayName;
          final userEmail = user.email;
          final userInitial = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U';
          final userId = user.uid;

          // Watch Statistics
          final projectsCount = ref.watch(userProjectsProvider(userId)).value?.length ?? 0;
          final tasksCount = ref.watch(userAssignedTasksProvider(userId)).value?.length ?? 0;
          final groupsCount = ref.watch(userGroupsProvider(userId)).value?.length ?? 0;
          
          // Watch Notification Count
          final unreadNotifs = ref.watch(unreadNotificationsCountProvider).value ?? 0;

          return Column(
            children: [
              _buildHeader(
                context, 
                userName, 
                userEmail, 
                userInitial, 
                user.photoURL,
                projectsCount: projectsCount,
                tasksCount: tasksCount,
                groupsCount: groupsCount,
                plan: user.plan,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Trang chủ',
                      color: AppColors.darkAccent,
                      isSelected: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      label: AppStrings.profile,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.pop(context),
                    ),
                    _NavItem(
                      icon: Icons.notifications_rounded,
                      label: AppStrings.notifications,
                      color: AppColors.darkWarning,
                      badge: unreadNotifs > 0 ? unreadNotifs.toString() : null,
                      onTap: () => Navigator.pop(context),
                    ),
                    _NavItem(
                      icon: Icons.settings_rounded,
                      label: 'Cài đặt',
                      color: AppColors.darkSuccess,
                      onTap: () => Navigator.pop(context),
                    ),
                    _NavItem(
                      icon: Icons.info_rounded,
                      label: 'Về ứng dụng',
                      color: AppColors.darkTextSecondary,
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              _buildLogout(context),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, stack) => Center(
          child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, 
    String name, 
    String email, 
    String initial, 
    String? photoURL, {
    required int projectsCount,
    required int tasksCount,
    required int groupsCount,
    required String plan,
  }) {
    final planLabel = plan.toUpperCase();
    final planColor = plan == 'free' ? const Color(0xFF64748B) : const Color(0xFFA78BFA);

    return Container(
      width: double.infinity,
      color: AppColors.darkSurface,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          // Background Glows
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.darkAccent.withOpacity(0.18), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accentDark, AppColors.darkAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkAccent.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                          image: photoURL != null
                              ? DecorationImage(
                                  image: NetworkImage(photoURL),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: photoURL == null
                            ? Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: -3,
                        right: -3,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.darkSuccess,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.darkSurface, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(number: projectsCount.toString(), label: 'DỰ ÁN'),
                      const SizedBox(width: 6),
                      _StatBox(number: tasksCount.toString(), label: 'TASK'),
                      const SizedBox(width: 6),
                      _StatBox(number: groupsCount.toString(), label: 'NHÓM'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: planColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: planColor.withOpacity(0.20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: planColor, size: 5),
                            const SizedBox(width: 6),
                            Text(
                              '$planLabel PLAN',
                              style: TextStyle(
                                color: planColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: AppColors.darkTextSecondary,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onLogout();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Thoát khỏi tài khoản',
                      style: TextStyle(color: Color(0xFF5A2020), fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF3A1A1A),
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String number;
  final String label;
  const _StatBox({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 9,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isSelected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.animationShort,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.darkAccent : const Color(0xFFC0CCDD),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.darkAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: AppColors.darkAccentLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF1E2D45),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.darkAccent.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
