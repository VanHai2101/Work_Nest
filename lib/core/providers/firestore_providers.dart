import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/data/repositories/firebase_user_repository.dart';
import '../data/repositories/call_repository.dart';

final userRepositoryProvider = Provider((ref) => FirebaseUserRepository());

// AUTH PROVIDERS (authStateProvider and userProfileProvider moved to features/auth)
final currentUserProvider = StreamProvider((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// SHARED PROVIDERS
final userProfileProvider = StreamProvider<UserEntity?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }
  final userRepo = ref.watch(userRepositoryProvider);
  yield* userRepo.getUserStream(user.uid);
});
