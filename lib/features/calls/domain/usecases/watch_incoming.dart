import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/call_entity.dart';
import '../../domain/repositories/call_repository.dart';

class WatchIncomingCallsUseCase implements StreamUseCase<CallEntity?, String> {
  final CallRepository _repository;

  WatchIncomingCallsUseCase(this._repository);

  @override
  Stream<CallEntity?> call(String userId) {
    return _repository.watchIncomingCalls(userId);
  }
}
