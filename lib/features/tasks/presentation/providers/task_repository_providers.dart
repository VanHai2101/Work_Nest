import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/firebase_task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});
