import 'dart:io';
import '../entities/chat_entity.dart';
import '../entities/message_entity.dart';
import '../entities/group_entity.dart';

abstract class IChatRepository {
  // ==========================================
  // REAL-TIME STREAMS (LẮNG NGHE TRỰC TIẾP)
  // ==========================================
  
  /// Lắng nghe danh sách Chat 1-1 của user
  Stream<List<ChatEntity>> watchChats(String userId);
  
  /// Lắng nghe tin nhắn trong 1 phòng Chat 1-1
  Stream<List<MessageEntity>> watchMessages(String chatId);
  
  /// Lắng nghe danh sách Group Chat của user
  Stream<List<GroupEntity>> watchGroups(String userId);
  
  /// Lắng nghe thông tin 1 phòng Chat 1-1
  Stream<ChatEntity?> watchChat(String chatId);

  /// Lắng nghe thông tin 1 Group Chat
  Stream<GroupEntity?> watchGroup(String groupId);

  /// Lắng nghe tin nhắn trong 1 Group Chat
  Stream<List<MessageEntity>> watchGroupMessages(String groupId);

  // ==========================================
  // HÀNH ĐỘNG GỬI TIN & TƯƠNG TÁC
  // ==========================================
  
  /// Gửi tin nhắn 1-1
  Future<void> sendMessage(String chatId, MessageEntity message);
  
  /// Gửi tin nhắn nhóm
  Future<void> sendGroupMessage(String groupId, MessageEntity message);
  
  /// Tạo mới chat 1-1 hoặc lấy ID nếu đã có
  Future<String> createOrGetChat(String currentUserId, String otherUserId);
  
  /// Đánh dấu đã đọc tin nhắn
  Future<void> markMessageAsRead(String chatId, String messageId, String userId, {bool isGroup = false});

  /// Upload ảnh lên storage
  Future<String> uploadImage(File file, String path);
}
