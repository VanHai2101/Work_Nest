import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/firebase_chat_repository.dart';
import 'package:work_nest/core/domain/entities/index.dart';
// Note: Bạn cần import Auth Provider của bạn để lấy current user id
// import 'package:work_nest/features/auth/application/providers/auth_providers.dart';

// 1. Cung cấp Repository (Singleton)
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return FirebaseChatRepository();
});

// 2. Lắng nghe danh sách phòng Chat 1-1 của User
final userChatsProvider = StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.watchChats(userId);
});

// 3. Lắng nghe tin nhắn trong 1 phòng Chat 1-1
final chatMessagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.watchMessages(chatId);
});

// 4. Lắng nghe danh sách Group Chat của User
final userGroupsProvider = StreamProvider.family<List<GroupEntity>, String>((ref, userId) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.watchGroups(userId);
});

// 5. Lắng nghe tin nhắn trong 1 Group Chat
final groupMessagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, groupId) {
  final repository = ref.read(chatRepositoryProvider);
  return repository.watchGroupMessages(groupId);
});
