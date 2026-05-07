import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/index.dart';

import 'search_repo_providers.dart';

final searchGlobalUseCaseProvider = Provider<SearchGlobalUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchGlobalUseCase(repository);
});
