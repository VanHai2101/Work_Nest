import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/data/models/index.dart';

import '../../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =================================================================
  // 1-1 CHATS
  // =================================================================

  @override
  Stream<List<ChatEntity>> watchChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromJson(doc.data(), id: doc.id).toEntity())
            .toList());
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), id: doc.id).toEntity())
            .toList());
  }

  @override
  Future<void> sendMessage(String chatId, MessageEntity message) async {
    final messageModel = MessageModel.fromEntity(message);
    
    final batch = _firestore.batch();
    
    // 1. Lưu tin nhắn vào Subcollection
    final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc(message.id);
    batch.set(messageRef, messageModel.toJson());

    // 2. Cập nhật lastMessage ở Collection Cha
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      // Theo logic sẽ cần cập nhật unreadCount cho người kia, nhưng phải qua Cloud Function hoặc Transaction để an toàn
    });

    await batch.commit();
  }

  @override
  Future<String> createOrGetChat(String currentUserId, String otherUserId) async {
    // Tìm các chat có mặt currentUserId
    final query = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .get();

    // Lọc thủ công do Firestore không hỗ trợ multiple arrayContains
    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participantIds'] ?? []);
      if (participants.contains(otherUserId) && participants.length == 2) {
        return doc.id; // Trả về ID nếu đã từng chat
      }
    }

    // Nếu chưa chat bao giờ -> Tạo mới
    final newChatRef = _firestore.collection('chats').doc();
    await newChatRef.set({
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newChatRef.id;
  }

  // =================================================================
  // GROUP CHATS
  // =================================================================

  @override
  Stream<List<GroupEntity>> watchGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupModel.fromJson(doc.data(), id: doc.id).toEntity())
            .toList());
  }

  @override
  Stream<List<MessageEntity>> watchGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), id: doc.id).toEntity())
            .toList());
  }

  @override
  Future<void> sendGroupMessage(String groupId, MessageEntity message) async {
    final messageModel = MessageModel.fromEntity(message);
    
    final batch = _firestore.batch();
    
    // 1. Lưu tin nhắn vào Subcollection
    final messageRef = _firestore.collection('groups').doc(groupId).collection('messages').doc(message.id);
    batch.set(messageRef, messageModel.toJson());

    // 2. Cập nhật thông tin Group Cha
    final groupRef = _firestore.collection('groups').doc(groupId);
    batch.update(groupRef, {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // =================================================================
  // CHUNG (Đánh dấu đã đọc)
  // =================================================================

  @override
  Future<void> markMessageAsRead(String chatId, String messageId, String userId, {bool isGroup = false}) async {
    final collectionName = isGroup ? 'groups' : 'chats';
    
    await _firestore
        .collection(collectionName)
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'readBy': FieldValue.arrayUnion([userId])
    });
  }
}
