import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/firebase_project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return FirebaseProjectRepository();
});

// Provider lấy danh sách Dự án của User cụ thể (Có filter nên không bị chặn bởi Rules)
final userProjectsProvider = StreamProvider.family<List<ProjectEntity>, String>((ref, userId) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectsByMember(userId);
});

final projectByIdProvider = FutureProvider.family<ProjectEntity?, String>((ref, projectId) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(projectId);
});
