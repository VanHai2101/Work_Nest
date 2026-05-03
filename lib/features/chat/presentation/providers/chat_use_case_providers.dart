import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/index.dart';
import '../usecases/index.dart';
import 'chat_repository_providers.dart';

final watchChatsUseCaseProvider = Provider<WatchChatsUseCase>((ref) {
  return WatchChatsUseCase(ref.watch(chatRepositoryProvider));
});

final watchMessagesUseCaseProvider = Provider<WatchMessagesUseCase>((ref) {
  return WatchMessagesUseCase(ref.watch(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
});
