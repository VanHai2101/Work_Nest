import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/member_projects.dart';

import 'proj_repo_providers.dart';

final getProjectsByMemberUseCaseProvider = Provider<GetProjectsByMemberUseCase>(
  (ref) {
    return GetProjectsByMemberUseCase(ref.watch(projectRepositoryProvider));
  },
);
