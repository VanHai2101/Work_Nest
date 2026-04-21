import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../widgets/index.dart';
import '../../domain/entities/index.dart';
import '../providers/index.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupChatScreen({required this.groupId, super.key});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleSend(String text) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final newMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.uid,
      text: text,
      sentAt: DateTime.now(),
    );

    await _sendMessage(newMessage);
  }

  Future<void> _handleImageSelected(File file) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // 1. Upload ảnh
      final repo = ref.read(chatRepositoryProvider);
      final fileName = 'groups/${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await repo.uploadImage(file, fileName);

      // 2. Gửi tin nhắn ảnh
      final newMessage = MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.uid,
        text: '',
        sentAt: DateTime.now(),
        type: 'image',
        attachments: [imageUrl],
      );

      await _sendMessage(newMessage);
    } catch (e) {
      _showError('Lỗi upload ảnh: $e');
    }
  }

  Future<void> _sendMessage(MessageEntity message) async {
    try {
      await ref
          .read(chatRepositoryProvider)
          .sendGroupMessage(widget.groupId, message);
    } catch (e) {
      _showError('Lỗi gửi tin nhắn: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.groupId));
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(groupAsync),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chưa có tin nhắn',
                    subtitle: 'Hãy bắt đầu cuộc trò chuyện nhóm!',
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwn = message.senderId == currentUser?.uid;
                    return ChatMessageBubble(
                      message: message,
                      isMe: isOwn,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.darkAccent),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppColors.darkTextSecondary),
                ),
              ),
            ),
          ),
          ChatInputEditor(
            onSend: _handleSend,
            onImageSelected: _handleImageSelected,
          ),
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar(AsyncValue groupAsync) {
    return AppBar(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.darkBorder),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: groupAsync.when(
        data: (group) => Row(
          children: [
            AppAvatar(
              id: group?.name ?? 'G',
              photoURL: group?.photoURL,
              size: 36,
              isGroup: true,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group?.name ?? 'Group Chat',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${group?.memberIds.length ?? 0} thành viên',
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        loading: () =>
            const Text('Đang tải...', style: TextStyle(fontSize: 14)),
        error: (_, _) =>
            const Text('Lỗi tải nhóm', style: TextStyle(fontSize: 14)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
