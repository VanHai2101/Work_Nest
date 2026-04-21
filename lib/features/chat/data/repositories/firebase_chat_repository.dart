import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/index.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<ChatEntity>> watchChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatModel.fromJson(doc.data(), id: doc.id).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    MessageModel.fromJson(doc.data(), id: doc.id).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(String chatId, MessageEntity message) async {
    final messageModel = MessageModel.fromEntity(message);

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final participants = List<String>.from(
      chatDoc.data()?['participantIds'] ?? [],
    );

    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, messageModel.toJson());

    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    final actorName = currentUser?.displayName ?? 'Someone';
    final actorPhotoURL = currentUser?.photoURL;
    // Truncate message preview to avoid leaking full content via notifications
    final preview = message.text.length > 60
        ? '${message.text.substring(0, 60)}...'
        : message.text;

    final otherUserIds = participants
        .where((id) => id != message.senderId)
        .toList();
    for (var userId in otherUserIds) {
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'userId': userId,
        'type': message.type == 'image' ? 'new_message' : 'new_message',
        'title': message.type == 'image' ? 'Đã gửi một ảnh' : 'Tin nhắn mới',
        'body': message.type == 'image' ? '$actorName đã gửi một ảnh' : '$actorName: "$preview"',
        'actorId': currentUser?.uid ?? '',
        'actorName': actorName,
        'actorPhotoURL': actorPhotoURL,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'relatedEntityId': chatId,
        'relatedEntityType': 'chat',
      });
    }

    await batch.commit();
  }

  @override
  Future<String> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<String> createOrGetChat(
    String currentUserId,
    String otherUserId,
  ) async {
    final ids = [currentUserId, otherUserId]..sort();
    final deterministicId = '${ids[0]}_${ids[1]}';

    final existingDoc = await _firestore
        .collection('chats')
        .doc(deterministicId)
        .get();

    if (existingDoc.exists) return deterministicId;

    await _firestore.collection('chats').doc(deterministicId).set({
      'participantIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'unreadCount': <String, int>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return deterministicId;
  }

  @override
  Stream<ChatEntity?> watchChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? ChatModel.fromJson(doc.data()!, id: doc.id).toEntity()
              : null,
        );
  }

  @override
  Stream<GroupEntity?> watchGroup(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map(
          (doc) => doc.exists
              ? GroupModel.fromJson(doc.data()!, id: doc.id).toEntity()
              : null,
        );
  }

  @override
  Stream<List<GroupEntity>> watchGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => GroupModel.fromJson(doc.data(), id: doc.id).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Stream<List<MessageEntity>> watchGroupMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    MessageModel.fromJson(doc.data(), id: doc.id).toEntity(),
              )
              .toList(),
        );
  }

  @override
  Future<void> sendGroupMessage(String groupId, MessageEntity message) async {
    final messageModel = MessageModel.fromEntity(message);
    final groupDoc = await _firestore.collection('groups').doc(groupId).get();
    final memberIds = List<String>.from(groupDoc.data()?['memberIds'] ?? []);
    final groupName = groupDoc.data()?['name'] as String? ?? 'A group';

    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, messageModel.toJson());

    final groupRef = _firestore.collection('groups').doc(groupId);
    batch.update(groupRef, {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    final actorName = currentUser?.displayName ?? 'Someone';
    final actorPhotoURL = currentUser?.photoURL;
    // Truncate message preview to avoid leaking full content via notifications
    final preview = message.text.length > 60
        ? '${message.text.substring(0, 60)}...'
        : message.text;

    final otherUserIds = memberIds
        .where((id) => id != message.senderId)
        .toList();
    for (var userId in otherUserIds) {
      final notifRef = _firestore.collection('notifications').doc();
      batch.set(notifRef, {
        'userId': userId,
        'type': 'group_message',
        'title': 'New message in $groupName',
        'body': '$actorName: "$preview"',
        'actorId': currentUser?.uid ?? '',
        'actorName': actorName,
        'actorPhotoURL': actorPhotoURL,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'relatedEntityId': groupId,
        'relatedEntityType': 'group',
      });
    }

    await batch.commit();
  }

  @override
  Future<void> markMessageAsRead(
    String chatId,
    String messageId,
    String userId, {
    bool isGroup = false,
  }) async {
    final collectionName = isGroup ? 'groups' : 'chats';

    await _firestore
        .collection(collectionName)
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'readBy': FieldValue.arrayUnion([userId]),
        });
  }
}
