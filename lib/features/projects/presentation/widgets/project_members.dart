import 'package:flutter/material.dart';
import '../../../../core/constants/index.dart';

class ProjectMembers extends StatelessWidget {
  final List<String> memberIds;

  const ProjectMembers({required this.memberIds, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Members',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${memberIds.length}',
                style: TextStyle(
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppLayout.gapMedium,
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: memberIds.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: AppPadding.small),
                child: Tooltip(
                  message: 'Member ${index + 1}',
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
