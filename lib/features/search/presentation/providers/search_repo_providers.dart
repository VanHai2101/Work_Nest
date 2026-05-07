import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/repositories/firebase_search_repository.dart';

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  return FirebaseSearchRepository();
});
