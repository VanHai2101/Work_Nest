import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/firebase_chat_repository.dart';

final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  return FirebaseChatRepository();
});
