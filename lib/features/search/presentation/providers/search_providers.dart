import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/features/search/data/repositories/search_repository.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchTypeFilterProvider = StateProvider<SearchResultType?>(
  (ref) => null,
);

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filterType = ref.watch(searchTypeFilterProvider);
  final repository = ref.watch(searchRepositoryProvider);

  if (query.length < 2) return [];

  // Thêm một chút delay để tránh query quá thường xuyên khi đang gõ (debounce)
  await Future.delayed(const Duration(milliseconds: 300));

  // Re-check query after delay
  if (query != ref.read(searchQueryProvider)) return [];

  return repository.searchGlobal(query, filterType: filterType);
});
