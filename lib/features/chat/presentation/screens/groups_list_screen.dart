import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/components/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/theme/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';
import 'index.dart';
import '../../../search/presentation/screens/index.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final groupsAsync = ref.watch(userGroupsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.groups_rounded,
                    title: AppStrings.noGroupsYet,
                    subtitle: AppStrings.createGroupToWork,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 90),
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 76,
                    endIndent: 16,
                    color: AppColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return GroupListTile(group: group);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.darkAccent),
              ),
              error: (err, stack) => Center(
                child: Text(
                  '${AppErrors.loadingFailed}: $err',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.searchGroup,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.darkAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkAccent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}

class GroupListTile extends ConsumerWidget {
  final GroupEntity group;

  const GroupListTile({required this.group, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberCount = group.memberIds.length;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: group.id)),
      ),
      splashColor: AppColors.surface,
      highlightColor: AppColors.surface.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                AppAvatar(
                  id: group.name,
                  photoURL: group.photoURL,
                  size: 48,
                  isGroup: true,
                ),
                // Member count badge
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryBackground,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 8,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$memberCount',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkAccent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$memberCount ${AppStrings.membersCount}',
                          style: TextStyle(
                            color: AppColors.darkAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    group.description ?? AppStrings.noDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
