import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/usecases/search_global.dart';

import 'search_uc_providers.dart';

// RE-EXPORT
export 'search_repo_providers.dart';
export 'search_uc_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchTypeFilterProvider = StateProvider<SearchResultType?>(
  (ref) => null,
);

final searchResultsProvider = FutureProvider<List<SearchResultEntity>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filterType = ref.watch(searchTypeFilterProvider);
  final searchGlobalUseCase = ref.watch(searchGlobalUseCaseProvider);

  if (query.length < 2) return [];

  // Thêm một chút delay để tránh query quá thường xuyên khi đang gõ (debounce)
  await Future.delayed(const Duration(milliseconds: 300));

  // Re-check query after delay
  if (query != ref.read(searchQueryProvider)) return [];

  final result = await searchGlobalUseCase.call(
    SearchGlobalParams(query: query, filterType: filterType),
  );

  return result.fold(
    (failure) => [], // Trả về list rỗng nếu lỗi
    (results) => results,
  );
});
