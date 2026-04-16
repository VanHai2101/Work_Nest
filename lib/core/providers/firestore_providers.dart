import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/group_repository.dart';
import '../data/repositories/call_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../domain/models/index.dart';

// Repositories
final chatRepositoryProvider = Provider((ref) => ChatRepository());
final groupRepositoryProvider = Provider((ref) => GroupRepository());
final callRepositoryProvider = Provider((ref) => CallRepository());
final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

// Current user
final currentUserProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ========== CHAT PROVIDERS ==========

final userChatsProvider = StreamProvider<List<Chat>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield [];
    return;
  }

  final chatRepo = ref.watch(chatRepositoryProvider);
  yield* chatRepo.getUserChats(user.uid);
});

final chatProvider = StreamProvider.family<Chat?, String>((ref, chatId) async* {
  final chatRepo = ref.watch(chatRepositoryProvider);
  yield* chatRepo.getChat(chatId);
});

final messagesProvider = StreamProvider.family<List<Message>, String>((ref, chatId) async* {
  final chatRepo = ref.watch(chatRepositoryProvider);
  yield* chatRepo.getMessages(chatId);
});

// Send message
final sendMessageProvider = FutureProvider.family<Message, (String, String)>((ref, args) async {
  final (chatId, message) = args;
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) throw Exception('User not authenticated');

  final chatRepo = ref.watch(chatRepositoryProvider);
  return chatRepo.addMessage(chatId, user.uid, user.displayName ?? 'Unknown', message);
});

// ========== GROUP PROVIDERS ==========

final userGroupsProvider = StreamProvider<List<Group>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield [];
    return;
  }

  final groupRepo = ref.watch(groupRepositoryProvider);
  yield* groupRepo.getUserGroups(user.uid);
});

final groupProvider = StreamProvider.family<Group?, String>((ref, groupId) async* {
  final groupRepo = ref.watch(groupRepositoryProvider);
  yield* groupRepo.getGroup(groupId);
});

final groupMessagesProvider = StreamProvider.family<List<Message>, String>((ref, groupId) async* {
  final groupRepo = ref.watch(groupRepositoryProvider);
  yield* groupRepo.getMessages(groupId);
});

// Send group message
final sendGroupMessageProvider = FutureProvider.family<Message, (String, String)>((ref, args) async {
  final (groupId, message) = args;
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) throw Exception('User not authenticated');

  final groupRepo = ref.watch(groupRepositoryProvider);
  return groupRepo.addMessage(groupId, user.uid, user.displayName ?? 'Unknown', message);
});

// ========== CALL PROVIDERS ==========

final callProvider = StreamProvider.family<Call?, String>((ref, callId) async* {
  final callRepo = ref.watch(callRepositoryProvider);
  yield* callRepo.getCall(callId);
});

// ========== NOTIFICATION PROVIDERS ==========

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield [];
    return;
  }

  final notifRepo = ref.watch(notificationRepositoryProvider);
  yield* notifRepo.getUserNotifications(user.uid);
});

final unreadNotificationCountProvider = StreamProvider<int>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield 0;
    return;
  }

  final notifRepo = ref.watch(notificationRepositoryProvider);
  yield* notifRepo.getUnreadCount(user.uid);
});
