import '../entities/search_result_entity.dart';

abstract class ISearchRepository {
  Future<List<SearchResultEntity>> searchGlobal(
    String query, {
    SearchResultType? filterType,
  });
}
