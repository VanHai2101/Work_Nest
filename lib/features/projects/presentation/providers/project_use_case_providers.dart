import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/get_projects_by_member_usecase.dart';
import 'project_repository_providers.dart';

final getProjectsByMemberUseCaseProvider = Provider<GetProjectsByMemberUseCase>(
  (ref) {
    return GetProjectsByMemberUseCase(ref.watch(projectRepositoryProvider));
  },
);
