import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_editor.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isGroup;

  const ChatDetailScreen({super.key, required this.chatId, this.isGroup = false});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(String text) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final newMsg = MessageEntity(
      id: const Uuid().v4(),
      senderId: currentUser.uid,
      text: text,
      sentAt: DateTime.now(),
      readBy: [currentUser.uid],
    );

    final repo = ref.read(chatRepositoryProvider);
    if (widget.isGroup) {
      repo.sendGroupMessage(widget.chatId, newMsg);
    } else {
      repo.sendMessage(widget.chatId, newMsg);
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider = widget.isGroup 
        ? groupMessagesProvider(widget.chatId) 
        : chatMessagesProvider(widget.chatId);
        
    final messagesStream = ref.watch(streamProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Hãy bắt đầu câu chuyện nhé! 👋',
                    subtitle: 'Gửi tin nhắn đầu tiên của bạn cho người ấy.',
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    
                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      showAvatar = messages[index + 1].senderId != msg.senderId;
                    }

                    return ChatMessageBubble(
                      message: msg,
                      isMe: isMe,
                      showAvatar: !isMe && showAvatar,
                      senderName: widget.isGroup ? 'Guest' : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkAccent)),
              error: (e, stack) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: AppColors.darkTextSecondary))),
            ),
          ),
          
          ChatInputEditor(
            onSend: _sendMessage,
            onAttach: () {},
            onCamera: () {},
            onVoice: () {},
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
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.darkBorder),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AppAvatar(
            id: widget.chatId,
            size: 38,
            isGroup: widget.isGroup,
            showOnline: true,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isGroup ? 'Team Work Group' : 'Tin nhắn',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Đang hoạt động',
                style: TextStyle(color: AppColors.darkSuccess, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkTextSecondary, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
