import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart';
import 'dart:io';
import '../../../../core/components/index.dart';
import '../widgets/index.dart';
import '../providers/index.dart';
import '../../domain/entities/index.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({required this.chatId, super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
      final fileName =
          'chats/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageUrl = await repo.uploadImage(file, fileName);

      // 2. Gửi tin nhắn ảnh
      final newMessage = MessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUser.uid,
        text: '', // Có thể thêm caption sau
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
          .sendMessage(widget.chatId, message);
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
                if (messages.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chưa có tin nhắn',
                    subtitle: 'Hãy gửi lời chào đầu tiên!',
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
                    return ChatMessageBubble(message: message, isMe: isOwn);
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
