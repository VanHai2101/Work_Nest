import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

class GetProjectsByMemberUseCase implements StreamUseCase<List<ProjectEntity>, String> {
  final ProjectRepository _repository;

  GetProjectsByMemberUseCase(this._repository);

  @override
  Stream<List<ProjectEntity>> call(String userId) {
    return _repository.getProjectsByMember(userId);
  }
}
