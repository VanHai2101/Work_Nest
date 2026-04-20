import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchResultType { user, project, group }

class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final String? photoURL;
  final SearchResultType type;
  final Map<String, dynamic> rawData;

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.photoURL,
    required this.type,
    required this.rawData,
  });

  factory SearchResult.fromFirestore(DocumentSnapshot doc, SearchResultType type) {
    final data = doc.data() as Map<String, dynamic>;
    if (type == SearchResultType.user) {
      return SearchResult(
        id: doc.id,
        title: data['displayName'] ?? 'Unknown User',
        subtitle: data['plan'] ?? 'free',
        photoURL: data['photoURL'],
        type: type,
        rawData: data,
      );
    } else {
      return SearchResult(
        id: doc.id,
        title: data['title'] ?? 'Unnamed Project',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    }
  }
}

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SearchResult>> searchGlobal(String query, {SearchResultType? filterType}) async {
    if (query.isEmpty) return [];
    
    final normalizedQuery = query.toLowerCase().trim();
    final results = <SearchResult>[];

    // Search Users
    if (filterType == null || filterType == SearchResultType.user) {
      final userSnap = await _firestore
          .collection('search_index')
          .doc('users')
          .collection('items')
          .where('keywords', arrayContains: normalizedQuery)
          .limit(10)
          .get();
      results.addAll(userSnap.docs.map((doc) => SearchResult.fromFirestore(doc, SearchResultType.user)));
    }

    // Search Projects
    if (filterType == null || filterType == SearchResultType.project) {
      final projectSnap = await _firestore
          .collection('search_index')
          .doc('projects')
          .collection('items')
          .where('keywords', arrayContains: normalizedQuery)
          .limit(10)
          .get();
      results.addAll(projectSnap.docs.map((doc) => SearchResult.fromFirestore(doc, SearchResultType.project)));
    }

    return results;
  }
}

final searchRepositoryProvider = Provider<SearchRepository>((ref) => SearchRepository());
