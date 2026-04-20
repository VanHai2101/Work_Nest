import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import '../../../../core/theme/index.dart';
import '../../../../core/components/index.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool showAvatar;
  final String? senderName;
  final String? senderPhotoUrl;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.senderName,
    this.senderPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            AppAvatar(id: message.senderId, photoURL: senderPhotoUrl, size: 32),
            const SizedBox(width: 8),
          ] else if (!isMe && !showAvatar) ...[
            const SizedBox(width: 40), // Placeholder for alignment
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showAvatar && senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      senderName!,
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                
                _buildMessageContainer(context),
              ],
            ),
          ),
          
          if (isMe) ...[
             const SizedBox(width: 6),
             if (message.readBy.length > 1)
               const Icon(Icons.done_all_rounded, size: 14, color: AppColors.darkAccent)
             else
               const Icon(Icons.done_rounded, size: 14, color: AppColors.darkTextSecondary),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.darkAccent : AppColors.darkCard,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        border: isMe ? null : Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(message.sentAt),
            style: TextStyle(
              color: isMe ? Colors.white.withOpacity(0.6) : AppColors.darkTextSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
