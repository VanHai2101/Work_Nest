// ─────────────────────────────────────────────
//  chat_screen.dart  (redesigned, no name changes)
// ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart';
import '../../../../core/components/index.dart';
import '../providers/chat_providers.dart';
import '../../domain/entities/message_entity.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({required this.chatId, super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
          .sendMessage(widget.chatId, newMessage);
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
              'Error sending message: $e',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) return _buildEmptyState();
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

  Widget _buildEmptyState() {
    return const AppEmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'No messages yet',
      subtitle: 'Say hello!',
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              child: Container(
                margin: EdgeInsets.only(
                  left: isOwn ? 48 : 0,
                  right: isOwn ? 0 : 48,
                  bottom: 2,
                ),
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
                    if (!showTime) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 10,
                              color: isOwn
                                  ? Colors.white.withOpacity(0.55)
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all_rounded,
                              size: 13,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
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
        border: const Border(top: BorderSide(color: AppColors.darkBorder)),
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

  PreferredSizeWidget _buildAppBar() {
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
      title: const Row(
        children: [
          AppAvatar(id: 'Chat', size: 36),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Đang hoạt động',
                style: TextStyle(color: Color(0xFF34D399), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.videocam_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
