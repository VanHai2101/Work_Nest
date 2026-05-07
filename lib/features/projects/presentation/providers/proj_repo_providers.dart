import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/repositories/firebase_project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return FirebaseProjectRepository();
});
