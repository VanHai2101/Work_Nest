import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/call_entity.dart';
import '../../domain/repositories/call_repository.dart';

class WatchCallUseCase implements StreamUseCase<CallEntity?, String> {
  final CallRepository _repository;

  WatchCallUseCase(this._repository);

  @override
  Stream<CallEntity?> call(String callId) {
    return _repository.watchCall(callId);
  }
}
