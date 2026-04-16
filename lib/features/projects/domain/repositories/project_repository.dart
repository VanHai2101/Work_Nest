import 'package:work_nest/core/domain/entities/index.dart';

abstract class ProjectRepository {
  Stream<List<ProjectEntity>> getProjects();
  Stream<List<ProjectEntity>> getProjectsByMember(String uid);
  Future<void> createProject(ProjectEntity project);
  Future<void> updateProject(ProjectEntity project);
  Future<void> deleteProject(String projectId);
  Future<ProjectEntity?> getProjectById(String projectId);
}
