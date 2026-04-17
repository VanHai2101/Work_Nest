import 'package:uuid/uuid.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/features/projects/domain/repositories/project_repository.dart';

import '../../domain/entities/project_entity.dart';

class ProjectSeeder {
  final ProjectRepository _repository;

  ProjectSeeder(this._repository);

  Future<void> seedSampleProjects(String currentUserId) async {
    final now = DateTime.now();
    final uuid = Uuid();

    // Utilizing AppColors.projectPalette for reusability instead of hardcoded hex strings
    final colors = AppColors.projectPalette;

    final sampleProjects = [
      ProjectEntity(
        id: uuid.v4(),
        title: 'Project Alpha',
        description: 'This is the first sample project created for testing.',
        ownerId: currentUserId,
        memberIds: [currentUserId],
        status: 'ongoing',
        progress: 0.1,
        dueDate: now.add(const Duration(days: 30)),
        createdAt: now,
        updatedAt: now,
        color:
            '#${colors[0].value.toRadixString(16).substring(2).toUpperCase()}',
        tags: ['development', 'internal'],
      ),
      ProjectEntity(
        id: uuid.v4(),
        title: 'WorkNest Mobile App',
        description:
            'Working on the cross-platform mobile application using Flutter.',
        ownerId: currentUserId,
        memberIds: [currentUserId],
        status: 'ongoing',
        progress: 0.45,
        dueDate: now.add(const Duration(days: 60)),
        createdAt: now,
        updatedAt: now,
        color:
            '#${colors[5].value.toRadixString(16).substring(2).toUpperCase()}',
        tags: ['design', 'mobile'],
      ),
      ProjectEntity(
        id: uuid.v4(),
        title: 'Marketing Campaign',
        description: 'Planning the Q3 marketing strategy and brand outreach.',
        ownerId: currentUserId,
        memberIds: [currentUserId],
        status: 'ongoing',
        progress: 0.0,
        dueDate: now.add(const Duration(days: 15)),
        createdAt: now,
        updatedAt: now,
        color:
            '#${colors[3].value.toRadixString(16).substring(2).toUpperCase()}',
        tags: ['marketing', 'brand'],
      ),
    ];

    for (var project in sampleProjects) {
      await _repository.createProject(project);
    }
  }
}
