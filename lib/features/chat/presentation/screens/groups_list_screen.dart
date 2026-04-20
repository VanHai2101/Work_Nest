import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../domain/entities/group_entity.dart';
import '../providers/chat_providers.dart';
import 'group_chat_screen.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final groupsAsync = ref.watch(userGroupsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.groups), elevation: 0),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.groups,
                    size: AppSize.iconXLarge,
                    color: Colors.grey.shade400,
                  ),
                  AppLayout.gapMedium,
                  Text(
                    AppStrings.noGroupsYet,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return GroupListTile(group: group);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('${AppErrors.loadingFailed}: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create group logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupListTile extends ConsumerWidget {
  final GroupEntity group;

  const GroupListTile({required this.group, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: group.id)),
        );
      },
      leading: CircleAvatar(
        backgroundImage: group.photoURL != null
            ? NetworkImage(group.photoURL!)
            : null,
        child: group.photoURL == null
            ? Text(group.name[0].toUpperCase())
            : null,
      ),
      title: Text(group.name),
      subtitle: Text(
        group.description ?? AppStrings.noDescription,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${group.memberIds.length}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Text(AppStrings.members, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
