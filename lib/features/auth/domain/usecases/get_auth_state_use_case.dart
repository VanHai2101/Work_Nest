import 'package:work_nest/core/usecases/usecase.dart';
import '../entities/index.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase implements StreamUseCase<UserEntity?, NoParams> {
  final IAuthRepository _repository;

  GetAuthStateUseCase(this._repository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return _repository.authStateChanges;
  }
}
