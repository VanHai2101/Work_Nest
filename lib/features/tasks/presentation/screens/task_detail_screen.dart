import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/index.dart';
import '../../../../core/components/dynamic_island/island_provider.dart';
import '../../domain/entities/index.dart';

import '../providers/index.dart';


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
        title: const Text('Chi tiết công việc'),

        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () {
              _showQRCode(context, 'worknest://task/${widget.taskId}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),

            onPressed: () {
              final link = 'worknest://task/${widget.taskId}';
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép liên kết!')),
              );

            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng chỉnh sửa sắp ra mắt')),
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
        error: (err, stack) => Center(child: Text('Lỗi: $err')),

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
                      task.completed ? 'Hoàn thành' : 'Chưa xong',

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
                        label: 'Mức độ',

                        value: task.priority.toUpperCase(),
                        valueColor: _getPriorityColor(task.priority),
                      ),
                    ),
                    AppLayout.horizontalGapMedium,
                    Expanded(
                      child: _buildInfoBox(
                        icon: Icons.calendar_today,
                        label: 'Hạn chót',

                        value: _formatDate(task.dueDate),
                      ),
                    ),
                  ],
                ),
                AppLayout.gapXLarge,

                // Description
                Text(
                  'Mô tả',

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
                    'Người thực hiện',

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
                    'Thẻ',

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

                AppLayout.gapXLarge,

                // Start Working Button
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(islandProvider.notifier).startTask(task.title);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã bắt đầu bộ đếm thời gian công việc'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Working on this Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                AppLayout.gapMedium,
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

  void _showQRCode(BuildContext context, String data) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task QR Code'),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

