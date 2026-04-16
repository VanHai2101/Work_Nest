import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:uuid/uuid.dart';
import '../../application/providers/chat_providers.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isGroup;

  const ChatDetailScreen({super.key, required this.chatId, this.isGroup = false});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final newMsg = MessageEntity(
      id: const Uuid().v4(),
      senderId: currentUser.uid,
      text: text,
      sentAt: DateTime.now(),
    );

    final repo = ref.read(chatRepositoryProvider);
    if (widget.isGroup) {
      repo.sendGroupMessage(widget.chatId, newMsg);
    } else {
      repo.sendMessage(widget.chatId, newMsg);
    }
    
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final streamProvider = widget.isGroup 
        ? groupMessagesProvider(widget.chatId) 
        : chatMessagesProvider(widget.chatId);
        
    final messagesStream = ref.watch(streamProvider);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.isGroup ? AppColors.warning : AppColors.success,
              child: Icon(widget.isGroup ? Icons.group : Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isGroup ? 'Group Chat' : 'Tin nhắn',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBackground,
        elevation: 1,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Hãy vẫy tay chào nhau nhé! 👋'));
                }
                return ListView.builder(
                  reverse: true, // Tin nhắn mới nhất nằm dưới
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.accent : AppColors.primaryBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ]
                        ),
                        child: Text(
                          msg.text,
                          style: AppTextStyles.body.copyWith(
                            color: isMe ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Lỗi: $e')),
            ),
          ),
          
          // INPUT KHUNG BỘ GÕ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryBackground,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
