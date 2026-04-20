import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/components/index.dart';
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

class HomeDashboardView extends ConsumerStatefulWidget {
  const HomeDashboardView({super.key});

  @override
  ConsumerState<HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends ConsumerState<HomeDashboardView> {
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
      backgroundColor: Colors.white,
      body: userProfile.when(
        data: (user) => _buildContent(user),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppColors.darkTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserEntity? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(user),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.recentProjects, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProjectsListScreen()),
            );
          }),
          const SizedBox(height: 12),
          _buildRecentProjects(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.recentTasks, () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TasksListScreen()));
          }),
          const SizedBox(height: 12),
          _buildRecentTasks(),
          const SizedBox(height: 24),
          _buildSectionHeader(AppStrings.quickActions, null),
          const SizedBox(height: 12),
          _buildQuickActions(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(UserEntity? user) {
    final name = user?.displayName ?? 'Người dùng';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
        ? 'Chào buổi chiều'
        : 'Chào buổi tối';

    return Row(
      children: [
        AppAvatar(
          id: user?.displayName ?? 'U',
          photoURL: user?.photoURL,
          size: 52,
          showOnline: false,
        ),
        AppLayout.horizontalGapMedium,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        // Today date pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.darkAccent,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                _todayLabel(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

  Widget _buildStatsGrid() {
    final projectsAsync = ref.watch(userProjectsProvider(currentUserId));
    final tasksAsync = ref.watch(userAssignedTasksProvider(currentUserId));

    return Row(
      children: [
        Expanded(
          child: projectsAsync.when(
            data: (projects) => _buildStatCard(
              AppStrings.projectsCount,
              projects.length.toString(),
              Icons.folder_copy_rounded,
              AppColors.darkAccent,
            ),
            loading: () => _buildStatCard(
              AppStrings.projectsCount,
              '—',
              Icons.folder_copy_rounded,
              AppColors.darkAccent,
            ),
            error: (_, _) => _buildStatCard(
              AppStrings.projectsCount,
              '!',
              Icons.folder_copy_rounded,
              AppColors.error,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: tasksAsync.when(
            data: (tasks) => _buildStatCard(
              AppStrings.tasksInProgress,
              tasks.where((t) => !t.completed).length.toString(),
              Icons.task_alt_rounded,
              AppColors.success,
            ),
            loading: () => _buildStatCard(
              AppStrings.tasksInProgress,
              '—',
              Icons.task_alt_rounded,
              AppColors.success,
            ),
            error: (_, _) => _buildStatCard(
              AppStrings.tasksInProgress,
              '!',
              Icons.task_alt_rounded,
              AppColors.error,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: tasksAsync.when(
            data: (tasks) => _buildStatCard(
              AppStrings.tasksCompleted,
              tasks.where((t) => t.completed).length.toString(),
              Icons.check_circle_rounded,
              const Color(0xFF8B5CF6),
            ),
            loading: () => _buildStatCard(
              AppStrings.tasksCompleted,
              '—',
              Icons.check_circle_rounded,
              const Color(0xFF8B5CF6),
            ),
            error: (_, _) => _buildStatCard(
              AppStrings.tasksCompleted,
              '!',
              Icons.check_circle_rounded,
              AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardLoading(String title, IconData icon, Color color) {
    return _buildStatCard(title, '—', icon, color);
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkAccent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                AppStrings.viewAll,
                style: TextStyle(
                  color: AppColors.darkAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          return _buildEmptyCard(
            AppStrings.noProjectsYet,
            Icons.folder_outlined,
          );
        }
        final recentProjects = projects.take(3).toList();
        return Column(
          children: recentProjects
              .map((p) => _buildProjectSmallCard(p))
              .toList(),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.darkAccent),
      ),
      error: (err, _) => const Center(
        child: Text(
          'Error loading projects',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }

  Widget _buildProjectSmallCard(ProjectEntity project) {
    final pct = (project.progress * 100).toInt();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.15)),
              ),
              child: Icon(
                Icons.folder_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: project.progress,
                            minHeight: 3,
                            backgroundColor: AppColors.surface,
                            valueColor: AlwaysStoppedAnimation(
                              pct >= 100 ? AppColors.success : AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkTextHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks() {
    final tasksAsync = ref.watch(userAssignedTasksProvider(currentUserId));

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return _buildEmptyCard(AppStrings.noTasksYet, Icons.task_alt_rounded);
        }
        final recentTasks =
            (tasks.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
                .take(3)
                .toList();
        return Column(
          children: recentTasks
              .map(
                (t) => TaskCard(
                  task: t,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(taskId: t.id),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.darkAccent),
      ),
      error: (err, _) => const Center(
        child: Text(
          'Error loading tasks',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String text, IconData icon) {
    return Container(
      height: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.darkTextHint, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: AppColors.darkTextHint, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (
        'Dự án mới',
        Icons.add_box_rounded,
        AppColors.warning,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateProjectScreen())),
      ),
      (
        'Giao việc',
        Icons.add_task_rounded,
        const Color(0xFF8B5CF6),
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreateTaskScreen())),
      ),
      ('Tin nhắn', Icons.message_rounded, const Color(0xFF14B8A6), () {}),
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final i = e.key;
        final (title, icon, color, onTap) = e.value;
        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(right: i < actions.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
