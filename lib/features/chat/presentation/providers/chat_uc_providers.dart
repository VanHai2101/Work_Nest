import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/index.dart';
import 'chat_repo_providers.dart';

final watchChatsUseCaseProvider = Provider<WatchChatsUseCase>((ref) {
  return WatchChatsUseCase(ref.watch(chatRepositoryProvider));
});

final watchMessagesUseCaseProvider = Provider<WatchMessagesUseCase>((ref) {
  return WatchMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});

final watchGroupsUseCaseProvider = Provider<WatchGroupsUseCase>((ref) {
  return WatchGroupsUseCase(ref.watch(chatRepositoryProvider));
});

final watchGroupMessagesUseCaseProvider = Provider<WatchGroupMessagesUseCase>((ref) {
  return WatchGroupMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final watchChatUseCaseProvider = Provider<WatchChatUseCase>((ref) {
  return WatchChatUseCase(ref.watch(chatRepositoryProvider));
});

final watchGroupUseCaseProvider = Provider<WatchGroupUseCase>((ref) {
  return WatchGroupUseCase(ref.watch(chatRepositoryProvider));
});

final markMessageAsReadUseCaseProvider = Provider<MarkMessageAsReadUseCase>((ref) {
  return MarkMessageAsReadUseCase(ref.watch(chatRepositoryProvider));
});

final createOrGetChatUseCaseProvider = Provider<CreateOrGetChatUseCase>((ref) {
  return CreateOrGetChatUseCase(ref.watch(chatRepositoryProvider));
});

final uploadChatImageUseCaseProvider = Provider<UploadChatImageUseCase>((ref) {
  return UploadChatImageUseCase(ref.watch(chatRepositoryProvider));
});

final sendGroupMessageUseCaseProvider = Provider<SendGroupMessageUseCase>((ref) {
  return SendGroupMessageUseCase(ref.watch(chatRepositoryProvider));
});


