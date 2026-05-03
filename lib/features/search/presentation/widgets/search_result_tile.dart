import 'package:flutter/material.dart';
import 'package:work_nest/core/components/app_avatar.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/features/search/domain/entities/search_result_entity.dart';
import 'package:work_nest/features/profile/presentation/screens/profile_screen.dart';
import 'package:work_nest/features/projects/presentation/screens/project_detail_screen.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResultEntity result;
  final VoidCallback? onTap;

  const SearchResultTile({required this.result, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final isUser = result.type == SearchResultType.user;
    final isProject = result.type == SearchResultType.project;
    final isTask = result.type == SearchResultType.task;
    final isGroup = result.type == SearchResultType.group;

    return ListTile(
      onTap:
          onTap ??
          () {
            if (isUser) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: result.id),
                ),
              );
            } else if (isProject) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDetailScreen(projectId: result.id),
                ),
              );
            } else if (isGroup) {
              // Add group navigation
            }
            // Add task navigation if needed
          },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: (isUser || isGroup)
          ? AppAvatar(
              id: result.title,
              userId: isUser ? result.id : null,
              photoURL: result.photoURL,
              size: 44,
              showOnline: isUser,
            )
          : Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isTask ? Colors.green : AppColors.accent).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isTask ? Icons.check_circle_outline_rounded : Icons.folder_rounded,
                color: isTask ? Colors.green : AppColors.accent,
                size: 22,
              ),
            ),
      title: Text(
        result.title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: result.subtitle != null
          ? Text(
              result.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            )
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (isUser ? Colors.blue : isTask ? Colors.green : Colors.orange).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isUser
              ? 'Người'
              : isTask
                  ? 'Nhiệm vụ'
                  : isGroup
                      ? 'Nhóm'
                      : 'Dự án',
          style: TextStyle(
            color:
                isUser
                    ? Colors.blue
                    : isTask
                        ? Colors.green
                        : isGroup
                            ? Colors.purple
                            : Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
