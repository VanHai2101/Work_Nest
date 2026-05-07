import 'package:work_nest/features/auth/presentation/providers/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_uc_providers.dart';

// RE-EXPORT for convenience in UI
export 'auth_repo_providers.dart';
export 'auth_uc_providers.dart';

// 1. Auth State Stream
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(getAuthStateUseCaseProvider).call(NoParams());
});

// 2. User Profile Stream
final userProfileProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(getUserProfileUseCaseProvider).call(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

// 3. Current User UID Provider (Helper)
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

// 4. User Profile by ID (Stream)
final userProfileByIdProvider = StreamProvider.family<UserEntity?, String>((ref, userId) {
  return ref.watch(getUserProfileUseCaseProvider).call(userId);
});

// Alias for compatibility
final currentUserProvider = userProfileProvider;
