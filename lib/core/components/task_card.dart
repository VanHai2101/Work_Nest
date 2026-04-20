import 'package:flutter/material.dart';
import '../theme/index.dart';
import '../constants/index.dart';
import '../../../features/tasks/domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const TaskCard({required this.task, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: EdgeInsets.only(bottom: AppPadding.small),
      padding: AppLayout.paddingSmall,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppBorderRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.completed,
          onChanged: null, // Static for dashboard view
          activeColor: AppColors.accent,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: priorityColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              task.priority,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Icon(Icons.calendar_today, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              '${task.dueDate.day}/${task.dueDate.month}',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
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
}
