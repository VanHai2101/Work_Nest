import 'package:work_nest/core/domain/entities/project_entity.dart';

abstract class ProjectRepository {
  Stream<List<ProjectEntity>> getProjects();
  Future<void> createProject(ProjectEntity project);
  Future<void> updateProject(ProjectEntity project);
  Future<void> deleteProject(String projectId);
  Future<ProjectEntity?> getProjectById(String projectId);
}
