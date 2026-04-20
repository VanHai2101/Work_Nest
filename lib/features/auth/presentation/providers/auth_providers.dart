import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../data/repositories/firebase_user_repository.dart';
import '../../domain/entities/user_entity.dart';

// 1. Repository Providers
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return FirebaseUserRepository();
});

// 2. Auth State Stream
// Sử dụng select để chỉ lắng nghe sự thay đổi của uid, giảm thiểu re-render
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// 3. User Profile Stream
// Tự động cập nhật khi authState thay đổi hoặc dữ liệu Firestore thay đổi
final userProfileProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      // Lắng nghe stream profile từ Firestore
      return ref.watch(userRepositoryProvider).getUserStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
});

// 4. Specific User Profile Stream
// Lấy thông tin profile của bất kỳ user nào qua UID
final userProfileByIdProvider = StreamProvider.family<UserEntity?, String>((ref, userId) {
  return ref.watch(userRepositoryProvider).getUserStream(userId);
});

// 5. Current User UID Provider (Helper)
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});
