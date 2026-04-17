import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/firebase_chat_repository.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/group_entity.dart';

// 1. Cung cấp Repository (Singleton)
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return FirebaseChatRepository();
});

// 2. Lắng nghe danh sách phòng Chat 1-1 của User
final userChatsProvider = StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchChats(userId);
});

// 3. Lắng nghe tin nhắn trong 1 phòng Chat 1-1
final chatMessagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(chatId);
});

// 4. Lắng nghe danh sách Group Chat của User
final userGroupsProvider = StreamProvider.family<List<GroupEntity>, String>((ref, userId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchGroups(userId);
});

// 5. Lắng nghe tin nhắn trong 1 Group Chat
final groupMessagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, groupId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchGroupMessages(groupId);
});

// 6. Lắng nghe thông tin 1 Group
final groupByIdProvider = StreamProvider.family<GroupEntity?, String>((ref, groupId) {
  final repository = ref.watch(chatRepositoryProvider);
  // We need to implement this in repository if not present, 
  // but for now let's assume watchGroups can be filtered or we add watchGroup
  return repository.watchGroups(FirebaseAuth.instance.currentUser?.uid ?? '').map(
    (groups) => groups.firstWhere((g) => g.id == groupId),
  );
});
