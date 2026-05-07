import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firebase_call_repository.dart';
import '../../domain/repositories/call_repository.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return FirebaseCallRepository();
});
