import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../repositories/index.dart';

class UploadChatImageParams {
  final File file;
  final String path;

  UploadChatImageParams({required this.file, required this.path});
}

class UploadChatImageUseCase implements UseCase<String, UploadChatImageParams> {
  final IChatRepository _repository;

  UploadChatImageUseCase(this._repository);

  @override
  Future<Either<OperationState, String>> call(UploadChatImageParams params) async {
    try {
      final imageUrl = await _repository.uploadImage(params.file, params.path);
      return Right(imageUrl);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
