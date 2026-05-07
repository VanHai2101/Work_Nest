import 'package:dartz/dartz.dart';
import 'package:work_nest/core/domain/states/operation_state.dart';
import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';

class SearchGlobalParams {
  final String query;
  final SearchResultType? filterType;

  SearchGlobalParams({required this.query, this.filterType});
}

class SearchGlobalUseCase implements UseCase<List<SearchResultEntity>, SearchGlobalParams> {
  final ISearchRepository _repository;

  SearchGlobalUseCase(this._repository);

  @override
  Future<Either<OperationState, List<SearchResultEntity>>> call(SearchGlobalParams params) async {
    try {
      final results = await _repository.searchGlobal(params.query, filterType: params.filterType);
      return Right(results);
    } catch (e) {
      return Left(OperationFailure(e.toString()));
    }
  }
}
