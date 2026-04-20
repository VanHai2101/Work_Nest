import 'dart:async';

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
final userChatsProvider = StreamProvider.family<List<ChatEntity>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchChats(userId);
});

// 3. Lắng nghe tin nhắn trong 1 phòng Chat 1-1
final chatMessagesProvider = StreamProvider.family<List<MessageEntity>, String>(
  (ref, chatId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchMessages(chatId);
  },
);

// 4. Lắng nghe danh sách Group Chat của User
final userGroupsProvider = StreamProvider.family<List<GroupEntity>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchGroups(userId);
});

// 5. Lắng nghe tin nhắn trong 1 Group Chat
final groupMessagesProvider =
    StreamProvider.family<List<MessageEntity>, String>((ref, groupId) {
      final repository = ref.watch(chatRepositoryProvider);
      return repository.watchGroupMessages(groupId);
    });

final groupByIdProvider = StreamProvider.family<GroupEntity?, String>((
  ref,
  groupId,
) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository
      .watchGroups(FirebaseAuth.instance.currentUser?.uid ?? '')
      .map(
        (groups) =>
            groups.isEmpty ? null : groups.firstWhere((g) => g.id == groupId),
      );
});

final unifiedConversationsProvider =
    StreamProvider.family<List<dynamic>, String>((ref, userId) {
      final chatsStream = ref.watch(userChatsProvider(userId).stream);
      final groupsStream = ref.watch(userGroupsProvider(userId).stream);

      List<ChatEntity> currentChats = [];
      List<GroupEntity> currentGroups = [];
      final controller = StreamController<List<dynamic>>();
      void emitCombined() {
        final combined = [...currentChats, ...currentGroups];
        combined.sort((a, b) {
          final dateA = (a is ChatEntity)
              ? a.lastMessageAt
              : (a as GroupEntity).lastMessageAt;
          final dateB = (b is ChatEntity)
              ? b.lastMessageAt
              : (b as GroupEntity).lastMessageAt;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        if (!controller.isClosed) controller.add(combined);
      }

      final chatsSub = chatsStream.listen(
        (chats) {
          currentChats = chats;
          emitCombined();
        },
        onError: (e) {
          emitCombined();
        },
      );

      final groupsSub = groupsStream.listen(
        (groups) {
          currentGroups = groups;
          emitCombined();
        },
        onError: (e) {
          emitCombined();
        },
      );

      ref.onDispose(() {
        chatsSub.cancel();
        groupsSub.cancel();
        controller.close();
      });
      return controller.stream;
    });

// 6. Tổng số tin nhắn chưa đọc
final totalUnreadCountProvider = Provider<int>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isEmpty) return 0;

  final conversationsAsync = ref.watch(unifiedConversationsProvider(userId));

  return conversationsAsync.when(
    data: (conversations) {
      int total = 0;
      for (final conv in conversations) {
        if (conv is ChatEntity) {
          total += conv.unreadCount[userId] ?? 0;
        } else if (conv is GroupEntity) {
          total += conv.unreadCount[userId] ?? 0;
        }
      }
      return total;
    },
    loading: () => 0,
    error: (_, _) => 0,
  );
});
