import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_providers.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupChatScreen({required this.groupId, super.key});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final newMessage = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.uid,
      text: text,
      sentAt: DateTime.now(),
    );

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendGroupMessage(widget.groupId, newMessage);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        );
      }
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
                    final showTime =
                        index == 0 ||
                        messages[index - 1].sentAt
                                .difference(message.sentAt)
                                .abs()
                                .inMinutes >
                            5;
                    return _buildBubble(message, isOwn, showTime);
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
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageEntity message, bool isOwn, bool showTime) {
    final timeStr =
        '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          if (showTime)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                timeStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ),
          Align(
            alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isOwn) ...[
                  AppAvatar(id: message.senderId, size: 28),
                  const SizedBox(width: 8),
                ],
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.65,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isOwn ? AppColors.darkAccent : AppColors.darkCard,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isOwn ? 18 : 4),
                        bottomRight: Radius.circular(isOwn ? 4 : 18),
                      ),
                      border: isOwn
                          ? null
                          : Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: isOwn
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (!isOwn)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'User ${message.senderId.substring(0, 4)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkAccent.withOpacity(0.8),
                              ),
                            ),
                          ),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isOwn
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.darkTextSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _handleSend(),
                  maxLines: null,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    hintStyle: TextStyle(
                      color: AppColors.darkTextHint,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.darkAccent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
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
