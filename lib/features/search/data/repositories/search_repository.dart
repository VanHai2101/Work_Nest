import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SearchResultType { user, project, task, group }

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

  factory SearchResult.fromFirestore(
    DocumentSnapshot doc,
    SearchResultType type,
  ) {
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
    } else if (type == SearchResultType.project) {
      return SearchResult(
        id: doc.id,
        title: data['title'] ?? 'Unnamed Project',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    } else {
      // Task
      return SearchResult(
        id: doc.id,
        title: data['title'] ?? 'Unnamed Task',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    }
  }
}

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SearchResult>> searchGlobal(
    String query, {
    SearchResultType? filterType,
  }) async {
    if (query.isEmpty) return [];

    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 2) return [];

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final results = <SearchResult>[];

    // Search Users - Scoped globally (all users are discoverable by signed-in users)
    if (filterType == null || filterType == SearchResultType.user) {
      try {
        final userSnap = await _firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: trimmedQuery)
            .where('displayName', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get();
        results.addAll(
          userSnap.docs.map(
            (doc) => SearchResult.fromFirestore(doc, SearchResultType.user),
          ),
        );
      } catch (e) {
        print('Search users error: $e');
        // Continue to other queries
      }
    }

    // Search Projects - Scoped to user's projects to satisfy security rules
    if (filterType == null || filterType == SearchResultType.project) {
      try {
        final projectSnap = await _firestore
            .collection('projects')
            .where('memberIds', arrayContains: currentUser.uid)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get();
        results.addAll(
          projectSnap.docs.map(
            (doc) => SearchResult.fromFirestore(doc, SearchResultType.project),
          ),
        );
      } catch (e) {
        print('Search projects error: $e');
        // Continue if projects fail (e.g. index missing)
      }
    }

    // Search Tasks - Scoped globally across projects via collectionGroup
    if (filterType == null || filterType == SearchResultType.task) {
      try {
        // Use collectionGroup to find tasks where user is creator
        final taskSnap = await _firestore
            .collectionGroup('tasks')
            .where('creatorId', isEqualTo: currentUser.uid)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get();
        results.addAll(
          taskSnap.docs.map(
            (doc) => SearchResult.fromFirestore(doc, SearchResultType.task),
          ),
        );
      } catch (e) {
        print('Search tasks error: $e');
      }
    }

    return results;
  }
}

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(),
);
