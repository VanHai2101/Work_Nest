import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

class GetUserProfileUseCase implements StreamUseCase<UserEntity?, String> {
  final IUserRepository _repository;

  GetUserProfileUseCase(this._repository);

  @override
  Stream<UserEntity?> call(String uid) {
    return _repository.getUserStream(uid);
  }
}
