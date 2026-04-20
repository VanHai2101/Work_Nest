import 'package:flutter/material.dart';
import '../theme/index.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const StatusBadge({required this.label, this.color, this.icon, super.key});

  factory StatusBadge.priority(String priority) {
    Color color;
    IconData icon;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        icon = Icons.priority_high_rounded;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.low_priority_rounded;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.arrow_downward_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline_rounded;
    }
    return StatusBadge(label: priority, color: color, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
