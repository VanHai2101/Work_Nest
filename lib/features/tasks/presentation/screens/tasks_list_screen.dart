import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart' show AppColors;
import '../../../../core/constants/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';
import 'index.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  late String currentUserId;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(userAssignedTasksProvider(currentUserId));

    return Scaffold(
      appBar: AppBar(title: const Text('Công việc của tôi'), centerTitle: true),

      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),

        data: (allTasks) {
          if (allTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task,
                    size: AppSize.iconXLarge,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  AppLayout.gapMedium,
                  Text(
                    'Chưa có công việc nào được giao',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),

                ],
              ),
            );
          }

          var tasks = allTasks;
          // Apply filter
          if (_filterStatus == 'pending') {
            tasks = tasks.where((t) => !t.completed).toList();
          } else if (_filterStatus == 'completed') {
            tasks = tasks.where((t) => t.completed).toList();
          }

          final statusMap = {
            'Tất cả': 'all',
            'Chưa xong': 'pending',
            'Hoàn thành': 'completed'
          };

          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: AppLayout.paddingMedium,
                child: Row(
                  children: statusMap.keys
                      .map(
                        (statusLabel) => Padding(
                          padding: EdgeInsets.only(right: AppPadding.small),
                          child: FilterChip(
                            label: Text(statusLabel),
                            selected: _filterStatus == statusMap[statusLabel],
                            onSelected: (selected) {
                              setState(() => _filterStatus = statusMap[statusLabel]!);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        );
                      },
                      onCompletionToggle: () {
                        ref
                            .read(taskRepositoryProvider)
                            .toggleTaskCompletion(
                              task.id,
                              task.projectId,
                              !task.completed,
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Công việc mới'),

        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onCompletionToggle;

  const _TaskTile({
    required this.task,
    required this.onTap,
    required this.onCompletionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppPadding.small),
        padding: AppLayout.paddingMedium,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppBorderRadius.medium,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) => onCompletionToggle(),
              activeColor: AppColors.accentDark,
            ),
            AppLayout.horizontalGapSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppLayout.gapSmall,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppLayout.horizontalGapSmall,
                      Icon(
                        Icons.calendar_today,
                        size: AppSize.iconSmall,
                        color: AppColors.textTertiary,
                      ),
                      AppLayout.horizontalGapSmall,
                      Text(
                        _formatDate(task.dueDate),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
