import 'package:flutter/material.dart';
import '../../../../core/constants/index.dart';

/// Profile menu drawer widget
class ProfileMenuDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileMenuDrawer({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1C1E), Color(0xFF0D0E10)],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF1A1C1E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: AppSize.avatarMedium / 2,
                    backgroundColor: Colors.blue.shade600,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: AppSize.iconMedium,
                    ),
                  ),
                  AppLayout.gapSmall,
                  const Text(
                    'User Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            _DrawerMenuItem(
              icon: Icons.person_outline,
              label: AppStrings.profile,
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
              },
            ),
            _DrawerMenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
            _DrawerMenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to help screen
              },
            ),
            _DrawerMenuItem(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to about screen
              },
            ),
            const Divider(color: Colors.white24),
            _DrawerMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual drawer menu item
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlight;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlight = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isHighlight ? Colors.red : Colors.white.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isHighlight ? Colors.red : Colors.white,
          fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
