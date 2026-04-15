import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';

// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Either<OperationState, Type>> call(Params params);
}

class NoParams {}
