import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/data/repositories/index.dart';
import 'index.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final userRepo = UserRepository();
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(AppErrors.genericError),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: userRepo.getUserStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(AppErrors.genericError));
          }

          final user = snapshot.data!;

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
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 50,
                        )
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
                      // TODO: Navigate to upgrade screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Upgrade feature coming soon')),
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
                      // TODO: Navigate to settings screen
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: AppBorderRadius.medium,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade300, size: AppSize.iconMedium),
          AppLayout.horizontalGapMedium,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                AppLayout.gapSmall,
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  AppLayout.gapSmall,
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
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
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
