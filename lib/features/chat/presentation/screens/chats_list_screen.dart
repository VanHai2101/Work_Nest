import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/features/chat/presentation/screens/index.dart';
import '../../../../core/components/index.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/providers/index.dart';
import '../../../../core/theme/index.dart';
import '../../../search/presentation/screens/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final conversationsAsync = ref.watch(unifiedConversationsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tin nhắn',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: conversationsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'Chưa có cuộc trò chuyện nào',
                    subtitle: 'Bắt đầu kết nối với đồng nghiệp ngay!',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    indent: 76,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ConversationListTile(item: item);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.darkAccent),
              ),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GestureDetector(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              SizedBox(width: 14),
              Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
              SizedBox(width: 10),
              Text(
                'Tìm kiếm tin nhắn...',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3B82F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }
}

class ConversationListTile extends ConsumerWidget {
  final dynamic item;

  const ConversationListTile({required this.item, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGroup = item is GroupEntity;

    if (isGroup) {
      final group = item as GroupEntity;
      return _buildTile(
        context,
        title: group.name,
        subtitle: group.lastMessage ?? 'Hãy bắt đầu thảo luận nhóm',
        time: group.lastMessageAt,
        photoURL: group.photoURL,
        id: group.id,
        isGroup: true,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: group.id)),
        ),
      );
    } else {
      final chat = item as ChatEntity;
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      // Tìm ID của người kia trong participantIds
      final otherUserId = chat.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () =>
            chat.participantIds.isNotEmpty ? chat.participantIds[0] : '',
      );

      final otherUserAsync = ref.watch(userProfileByIdProvider(otherUserId));

      return otherUserAsync.when(
        data: (user) => _buildTile(
          context,
          title: user?.displayName ?? 'Người dùng',
          subtitle: chat.lastMessage ?? 'Bắt đầu trò chuyện',
          time: chat.lastMessageAt,
          photoURL: user?.photoURL,
          id: otherUserId,
          isGroup: false,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id)),
          ),
        ),
        loading: () => _buildShimmerTile(),
        error: (_, _) => const SizedBox.shrink(),
      );
    }
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required DateTime? time,
    required String? photoURL,
    required String id,
    required bool isGroup,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AppAvatar(
              id: id,
              userId: isGroup ? null : id,
              photoURL: photoURL,
              size: 52,
              isGroup: isGroup,
              showOnline: !isGroup,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time != null)
                        Text(
                          _formatTime(time),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge tin nhắn chưa đọc có thể thêm ở đây
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const CircleAvatar(radius: 26, backgroundColor: Color(0xFFF1F5F9)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 12,
                  color: const Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 10, color: Color(0xFFF1F5F9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) {
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
