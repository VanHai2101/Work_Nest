import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/index.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/tasks_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String? projectId;

  const TaskDetailScreen({required this.taskId, this.projectId, super.key});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(
      taskProvider((taskId: widget.taskId, projectId: widget.projectId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (task) {
          if (task == null) {
            return Center(child: Text(AppErrors.genericError));
          }

          return SingleChildScrollView(
            padding: AppLayout.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppLayout.gapMedium,

                // Title
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppLayout.gapSmall,

                // Status
                Row(
                  children: [
                    Checkbox(
                      value: task.completed,
                      onChanged: (_) {
                        ref
                            .read(taskRepositoryProvider)
                            .toggleTaskCompletion(
                              task.id,
                              task.projectId,
                              !task.completed,
                            );
                      },
                    ),
                    Text(
                      task.completed ? 'Completed' : 'Pending',
                      style: TextStyle(
                        color: task.completed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AppLayout.gapXLarge,

                // Priority & Due Date
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        icon: Icons.flag,
                        label: 'Priority',
                        value: task.priority.toUpperCase(),
                        valueColor: _getPriorityColor(task.priority),
                      ),
                    ),
                    AppLayout.horizontalGapMedium,
                    Expanded(
                      child: _buildInfoBox(
                        icon: Icons.calendar_today,
                        label: 'Due Date',
                        value: _formatDate(task.dueDate),
                      ),
                    ),
                  ],
                ),
                AppLayout.gapXLarge,

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppLayout.gapSmall,
                Container(
                  padding: AppLayout.paddingMedium,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: AppBorderRadius.medium,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ),
                AppLayout.gapXLarge,

                // Assignees
                if (task.assigneeIds.isNotEmpty) ...[
                  Text(
                    'Assignees',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppLayout.gapSmall,
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: task.assigneeIds.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: AppPadding.small),
                          child: CircleAvatar(
                            backgroundColor: Colors.blue.shade600,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  AppLayout.gapXLarge,
                ],

                // Tags
                if (task.tags.isNotEmpty) ...[
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppLayout.gapSmall,
                  Wrap(
                    spacing: AppPadding.small,
                    runSpacing: AppPadding.small,
                    children: task.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBox({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: AppLayout.paddingMedium,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppSize.iconSmall,
                color: Colors.white.withOpacity(0.5),
              ),
              AppLayout.horizontalGapSmall,
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          AppLayout.gapSmall,
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final taskRepo = ref.read(taskRepositoryProvider);
              final task = await taskRepo.getTaskById(widget.taskId);
              if (task != null) {
                await taskRepo.deleteTask(widget.taskId, task.projectId);
              }
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Task deleted')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
