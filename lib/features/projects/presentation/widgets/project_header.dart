import 'package:flutter/material.dart';
import '../../../../core/constants/index.dart';
import '../../domain/entities/project_entity.dart';

class ProjectHeader extends StatelessWidget {
  final ProjectEntity project;

  const ProjectHeader({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                project.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(project.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project.status,
                style: TextStyle(
                  color: _getStatusColor(project.status),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        AppLayout.gapMedium,
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: AppSize.iconSmall,
              color: Colors.white.withOpacity(0.5),
            ),
            AppLayout.horizontalGapSmall,
            Text(
              'Due: ${_formatDate(project.dueDate)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'on hold':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
