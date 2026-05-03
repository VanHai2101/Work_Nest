import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/index.dart';

abstract class UseCase<T, Params> {
  Future<Either<OperationState, T>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

class NoParams {}
