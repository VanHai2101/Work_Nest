import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/index.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create group
  Future<Group> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
    required String adminId,
    String? photoURL,
  }) async {
    final groupRef = _firestore.collection('groups').doc();

    final group = Group(
      id: groupRef.id,
      name: name,
      description: description,
      adminIds: [adminId],
      memberIds: memberIds,
      photoURL: photoURL,
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCount: {for (var id in memberIds) id: 0},
      createdAt: DateTime.now(),
    );

    await groupRef.set(group.toMap());
    return group;
  }

  // Get user's groups
  Stream<List<Group>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Group.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get single group
  Stream<Group?> getGroup(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Group.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Add message
  Future<Message> addMessage(
    String groupId,
    String senderId,
    String senderName,
    String text,
  ) async {
    final messageRef = _firestore
        .collection('groups')
        .doc(groupId)
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

    // Update group's last message
    await _firestore.collection('groups').doc(groupId).update({
      'lastMessage': text,
      'lastMessageAt': DateTime.now(),
    });

    return message;
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
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

  // Add member to group
  Future<void> addMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'unreadCount.$userId': 0,
    });
  }

  // Remove member from group
  Future<void> removeMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
    });
  }

  // Update unread count
  Future<void> updateUnreadCount(
    String groupId,
    String userId,
    int count,
  ) async {
    await _firestore.collection('groups').doc(groupId).update({
      'unreadCount.$userId': count,
    });
  }

  // Delete group
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }
}
