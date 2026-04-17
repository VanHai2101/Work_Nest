import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/projects_provider.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/tasks_provider.dart';
import '../../../projects/presentation/screens/index.dart';
import '../../../tasks/presentation/screens/index.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: userProfile.when(
        data: (user) => _buildContent(user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildContent(UserEntity? user) {
    return SingleChildScrollView(
      padding: AppLayout.paddingMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          AppLayout.gapLarge,
          _buildStatsGrid(),
          AppLayout.gapLarge,
          _buildSectionHeader('Dự án gần đây', () {
            // In a real app, you'd use a provider or controller to switch tabs
          }),
          AppLayout.gapMedium,
          _buildRecentProjects(),
          AppLayout.gapLarge,
          _buildSectionHeader('Hành động nhanh', null),
          AppLayout.gapMedium,
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(UserEntity? user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.accent.withOpacity(0.2),
          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child: user?.photoURL == null
              ? Text(
                  user?.displayName[0].toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        AppLayout.horizontalGapMedium,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào,',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            Text(
              user?.displayName ?? 'Người dùng',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final projectsAsync = ref.watch(userProjectsProvider(currentUserId));
    final tasksAsync = ref.watch(userAssignedTasksProvider(currentUserId));

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppPadding.medium,
      crossAxisSpacing: AppPadding.medium,
      childAspectRatio: 1.5,
      children: [
        projectsAsync.when(
          data: (projects) => _buildStatCard(
            'Dự án',
            projects.length.toString(),
            Icons.folder_copy_outlined,
            Colors.blue,
          ),
          loading: () => _buildStatCardLoading('Dự án', Icons.folder_copy_outlined, Colors.blue),
          error: (_, __) => _buildStatCard('Dự án', '!', Icons.folder_copy_outlined, Colors.red),
        ),
        tasksAsync.when(
          data: (tasks) => _buildStatCard(
            'Công việc',
            tasks.where((t) => !t.completed).length.toString(),
            Icons.task_alt,
            Colors.green,
          ),
          loading: () => _buildStatCardLoading('Công việc', Icons.task_alt, Colors.green),
          error: (_, __) => _buildStatCard('Công việc', '!', Icons.task_alt, Colors.red),
        ),
      ],
    );
  }

  Widget _buildStatCardLoading(String title, IconData icon, Color color) {
    return _buildStatCard(title, '...', icon, color);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppLayout.gapSmall,
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onMore != null)
          TextButton(
            onPressed: onMore,
            child: Text(
              'Xem tất cả',
              style: TextStyle(color: AppColors.accent, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentProjects() {
    final projectsAsync = ref.watch(userProjectsProvider(currentUserId));

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppBorderRadius.medium,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Chưa có dự án nào',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          );
        }

        final recentProjects = projects.take(3).toList();
        return Column(
          children: recentProjects.map((p) => _buildProjectSmallCard(p)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading projects')),
    );
  }

  Widget _buildProjectSmallCard(ProjectEntity project) {
    return Container(
      margin: EdgeInsets.only(bottom: AppPadding.small),
      padding: AppLayout.paddingSmall,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.folder, color: AppColors.accent, size: 20),
        ),
        title: Text(
          project.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Tiến độ: ${(project.progress * 100).toInt()}%',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(projectId: project.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionItem(
          'Dự án mới',
          Icons.add_box_outlined,
          Colors.orange,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
            );
          },
        ),
        AppLayout.horizontalGapMedium,
        _buildActionItem(
          'Giao việc',
          Icons.add_task,
          Colors.purple,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
            );
          },
        ),
        AppLayout.horizontalGapMedium,
        _buildActionItem(
          'Tin nhắn',
          Icons.message_outlined,
          Colors.teal,
          () {
            // Switch to chats tab
          },
        ),
      ],
    );
  }

  Widget _buildActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.medium,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppBorderRadius.medium,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              AppLayout.gapSmall,
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
