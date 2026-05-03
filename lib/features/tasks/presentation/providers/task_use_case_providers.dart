import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/index.dart';
import 'task_repository_providers.dart';

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final getTasksByProjectUseCaseProvider = Provider<GetTasksByProjectUseCase>((
  ref,
) {
  return GetTasksByProjectUseCase(ref.watch(taskRepositoryProvider));
});

// Add more use case providers here as they are refactored
