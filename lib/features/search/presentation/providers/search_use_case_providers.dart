import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/search_global_use_case.dart';
import 'search_repository_providers.dart';

final searchGlobalUseCaseProvider = Provider<SearchGlobalUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchGlobalUseCase(repository);
});
