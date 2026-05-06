import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectByIdProvider(widget.projectId));

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          AppStrings.projectDetails,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_2_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              _showQRCode(context, 'worknest://project/${widget.projectId}');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,

              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              final link = 'worknest://project/${widget.projectId}';
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép liên kết dự án!')),
              );

            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text(AppStrings.edit)));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),

      body: projectAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.darkAccent),
        ),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (project) {
          if (project == null) {
            return Center(child: Text(AppErrors.genericError));
          }

          return SingleChildScrollView(
            padding: AppLayout.paddingMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                ProjectHeader(project: project),
                AppLayout.gapXLarge,

                // Stats
                ProjectStats(project: project),
                AppLayout.gapXLarge,

                // Description
                Text(
                  AppStrings.description,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                AppLayout.gapSmall,
                Container(
                  padding: AppLayout.paddingMedium,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppBorderRadius.medium,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    project.description.isNotEmpty
                        ? project.description
                        : AppStrings.noDescription,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                AppLayout.gapXLarge,

                // Members
                ProjectMembers(memberIds: project.memberIds),
                AppLayout.gapXLarge,

                // Tags
                if (project.tags.isNotEmpty) ...[
                  Text(
                    AppStrings.tags,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  AppLayout.gapSmall,
                  Wrap(
                    spacing: AppPadding.small,
                    runSpacing: AppPadding.small,
                    children: project.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppColors.info,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.large),
        title: const Text(
          AppStrings.deleteProject,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(AppStrings.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(projectRepositoryProvider)
                  .deleteProject(widget.projectId);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.projectDeleted)),
                );
              }
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context, String data) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project QR Code'),
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

