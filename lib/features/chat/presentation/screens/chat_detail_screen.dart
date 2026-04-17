import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/index.dart';
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
    
    // Auto scroll to bottom
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
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: 16),
                        Text(
                          'Hãy bắt đầu câu chuyện nhé! 👋',
                          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    
                    // Logic for showing avatar (only for first message in a group by same user)
                    bool showAvatar = true;
                    if (index < messages.length - 1) {
                      showAvatar = messages[index + 1].senderId != msg.senderId;
                    }

                    return ChatMessageBubble(
                      message: msg,
                      isMe: isMe,
                      showAvatar: !isMe && showAvatar,
                      senderName: widget.isGroup ? 'Guest' : null, // Would fetch actual name in production
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Lỗi: $e')),
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
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.surface,
                child: Icon(widget.isGroup ? Icons.group_rounded : Icons.person_rounded, 
                  color: AppColors.accent, size: 22),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBackground, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isGroup ? 'Team Work Group' : 'Tin nhắn',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
              ),
              Text(
                'Đang hoạt động',
                style: AppTextStyles.caption.copyWith(color: AppColors.success, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.call_rounded, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
