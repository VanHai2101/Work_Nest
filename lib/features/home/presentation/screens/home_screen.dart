import '../../../auth/presentation/providers/index.dart';
import 'package:work_nest/features/auth/presentation/providers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/providers/index.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/presentation/screens/index.dart';
import '../../../notifications/presentation/screens/index.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../projects/presentation/screens/index.dart';
import '../../../tasks/presentation/screens/index.dart';
import 'package:work_nest/features/calendar/presentation/screens/calendar_screen.dart'
    as cal;
import '../../../profile/presentation/screens/index.dart';
import '../widgets/index.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../../search/presentation/screens/index.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens = [
    const HomeDashboardView(),
    const ChatsListScreen(),
    const cal.CalendarScreen(),
    const ProjectsListScreen(),
    const NotificationsScreen(),
  ];

  late final List<String> _titles = [
    'Trang chủ',
    AppStrings.chats,
    'Lịch trình',
    'Dự án',
    'Thông báo',
  ];

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _selectedIndex = 0);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: _buildAppBar(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _screens[_selectedIndex],
          ),
        ),
        bottomNavigationBar: AppBottomNavbar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.border),
      ),
      title: Text(
        _titles[_selectedIndex],
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        _appBarBtn(Icons.search_rounded, () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
        }),
        if (_selectedIndex == 4)
          _appBarBtn(Icons.done_all_rounded, () {})
        else
          _notificationBtn(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _appBarBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _notificationBtn() {
    final unreadCountAsync = ref.watch(unreadNotificationsCountProvider);

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 4),
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
                size: 20,
              ),
            ),
            unreadCountAsync.when(
              data: (count) {
                if (count <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
