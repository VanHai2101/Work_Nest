import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart' show AppColors, AppLayout, AppBorderRadius, AppSize;
import '../../../../core/constants/index.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: userProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text(AppErrors.genericError)),
        data: (user) {
          if (user == null) {
            return Center(child: Text(AppErrors.genericError));
          }

          return SingleChildScrollView(
            padding: AppLayout.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppLayout.gapLarge,

                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade600,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, color: Colors.white, size: 50)
                      : ClipOval(
                          child: Image.network(
                            user.photoURL!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                AppLayout.gapMedium,

                // Name
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppLayout.gapSmall,

                // Email
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                AppLayout.gapXLarge,

                // Plan Info Card
                _buildInfoCard(
                  icon: Icons.star,
                  title: 'Current Plan',
                  value: user.plan.toUpperCase(),
                  subtitle: user.planExpiresAt != null
                      ? 'Expires: ${_formatDate(user.planExpiresAt!)}'
                      : 'Free forever',
                ),
                AppLayout.gapMedium,

                // Member Since Card
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Member Since',
                  value: _formatDate(user.createdAt),
                ),
                AppLayout.gapXLarge,

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upgrade),
                    label: const Text('Upgrade Plan'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upgrade feature coming soon'),
                        ),
                      );
                    },
                  ),
                ),
                AppLayout.gapSmall,

                SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon')),
                      );
                    },
                  ),
                ),
                AppLayout.gapSmall,

                SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ),
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
