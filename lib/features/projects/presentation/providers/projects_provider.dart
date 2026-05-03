import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project_entity.dart';
import 'project_use_case_providers.dart';
import 'project_repository_providers.dart';

// RE-EXPORT
export 'project_repository_providers.dart';
export 'project_use_case_providers.dart';

final userProjectsProvider = StreamProvider.family<List<ProjectEntity>, String>((ref, userId) {
  return ref.watch(getProjectsByMemberUseCaseProvider).call(userId);
});

// For now, marked for refactoring
final projectByIdProvider = FutureProvider.family<ProjectEntity?, String>((ref, projectId) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(projectId);
});
