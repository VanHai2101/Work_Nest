import '../../domain/usecases/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/theme/index.dart';
import 'dart:io';
import '../../../../core/components/index.dart';
import '../../../auth/presentation/providers/index.dart';
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
      // 1. Upload ảnh qua UseCase
      final fileName =
          'chats/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await ref.read(uploadChatImageUseCaseProvider).call(
        UploadChatImageParams(file: file, path: fileName),
      );

      result.fold(
        (failure) => _showError('Lỗi upload ảnh: ${failure.message}'),
        (imageUrl) async {
          // 2. Gửi tin nhắn ảnh qua UseCase
          final newMessage = MessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            senderId: currentUser.uid,
            text: '',
            sentAt: DateTime.now(),
            type: 'image',
            attachments: [imageUrl],
          );

          await _sendMessage(newMessage);
        },
      );
    } catch (e) {
      _showError('Lỗi không xác định: $e');
    }
  }

  Future<void> _sendMessage(MessageEntity message) async {
    final result = await ref.read(sendMessageUseCaseProvider).call(
      SendMessageParams(chatId: widget.chatId, message: message),
    );

    result.fold(
      (failure) => _showError('Lỗi gửi tin nhắn: ${failure.message}'),
      (_) => null, // Thành công
    );
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
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(chatAsync),
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

  PreferredSizeWidget _buildAppBar(AsyncValue<ChatEntity?> chatAsync) {
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
      title: chatAsync.when(
        data: (chat) {
          if (chat == null) {
            return const Text(
              'Chat',
              style: TextStyle(color: Colors.white, fontSize: 14),
            );
          }

          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final otherUserId = chat.participantIds.firstWhere(
            (id) => id != currentUserId,
            orElse: () => chat.participantIds[0],
          );

          final otherUserAsync = ref.watch(
            userProfileByIdProvider(otherUserId),
          );
          final isOnlineAsync = ref.watch(
            userOnlineStatusProvider(otherUserId),
          );

          return otherUserAsync.when(
            data: (user) => Row(
              children: [
                AppAvatar(
                  id: user?.displayName ?? '?',
                  userId: otherUserId,
                  photoURL: user?.photoURL,
                  size: 36,
                  showOnline: true,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Người dùng',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      (isOnlineAsync.value ?? false)
                          ? 'Đang hoạt động'
                          : 'Ngoại tuyến',
                      style: TextStyle(
                        color: (isOnlineAsync.value ?? false)
                            ? AppColors.darkSuccess
                            : AppColors.darkTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Text(
              'Đang tải...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            error: (_, _) => const Text(
              'Lỗi',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          );
        },
        loading: () => const Text(
          'Đang tải...',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        error: (_, _) => const Text(
          'Lỗi',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
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
