import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/index.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create chat or get existing
  Future<Chat> createOrGetChat(String uid1, String uid2) async {
    final ids = [uid1, uid2]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    final chatRef = _firestore.collection('chats').doc(chatId);
    final doc = await chatRef.get();

    if (doc.exists) {
      return Chat.fromMap(doc.data()!, chatId);
    }

    final chat = Chat(
      id: chatId,
      participantIds: [uid1, uid2],
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCount: {uid1: 0, uid2: 0},
      createdAt: DateTime.now(),
    );

    await chatRef.set(chat.toMap());
    return chat;
  }

  // Get user's chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Chat.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single chat
  Stream<Chat?> getChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Chat.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Add message
  Future<Message> addMessage(
    String chatId,
    String senderId,
    String senderName,
    String text,
  ) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = Message(
      id: messageRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      sentAt: DateTime.now(),
      type: 'text',
    );

    await messageRef.set(message.toMap());

    // Update chat's last message
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': DateTime.now(),
    });

    return message;
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId, String userId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  // Delete message
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
      'deletedAt': DateTime.now(),
    });
  }

  // Update unread count
  Future<void> updateUnreadCount(
    String chatId,
    String userId,
    int count,
  ) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': count,
    });
  }
}
