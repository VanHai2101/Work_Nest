import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../chat/presentation/screens/index.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../projects/presentation/screens/index.dart';
import '../../../tasks/presentation/screens/tasks_list_screen.dart';
import '../../../profile/presentation/screens/index.dart';
import '../widgets/index.dart';

/// Home screen - main navigation hub
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // List of screens for bottom navigation
  late final List<Widget> _screens = [
    const ChatsListScreen(),
    const TasksListScreen(),
    const ProjectsListScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  late final List<String> _titles = [
    AppStrings.chats,
    'Tasks',
    'Projects',
    AppStrings.notifications,
    AppStrings.profile,
  ];

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          // Notifications badge (if not already on notifications tab)
          if (_selectedIndex != 3)
            Padding(
              padding: AppLayout.paddingMedium,
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      setState(() => _selectedIndex = 3);
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Menu button
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: ProfileMenuDrawer(
        onLogout: () {
          FirebaseAuth.instance.signOut();
          Navigator.of(context).pushReplacementNamed('/login');
        },
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_outlined),
            activeIcon: const Icon(Icons.chat),
            label: AppStrings.chats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_outlined),
            activeIcon: const Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.folder_outlined),
            activeIcon: const Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications),
            label: AppStrings.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}
