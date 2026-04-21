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
        title: data['displayName'] ?? 'Người dùng không tên',
        subtitle: data['plan'] ?? 'Gói miễn phí',
        photoURL: data['photoURL'],
        type: type,
        rawData: data,
      );
    } else if (type == SearchResultType.project) {
      return SearchResult(
        id: doc.id,
        title: data['title'] ?? 'Dự án không tên',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    } else if (type == SearchResultType.group) {
      return SearchResult(
        id: doc.id,
        title: data['name'] ?? 'Nhóm không tên',
        subtitle: data['description'],
        photoURL: data['photoURL'],
        type: type,
        rawData: data,
      );
    } else {
      // Task
      return SearchResult(
        id: doc.id,
        title: data['title'] ?? 'Công việc không tên',
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

    // Parallel search execution
    final searchFutures = <Future<void>>[];

    // 1. Search Users
    if (filterType == null || filterType == SearchResultType.user) {
      searchFutures.add(
        _firestore
            .collection('users')
            .where('displayName', isGreaterThanOrEqualTo: trimmedQuery)
            .where('displayName', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
          results.addAll(
            snap.docs.map(
              (doc) => SearchResult.fromFirestore(doc, SearchResultType.user),
            ),
          );
        }).catchError((_) {}),
      );
    }

    // 2. Search Projects
    if (filterType == null || filterType == SearchResultType.project) {
      searchFutures.add(
        _firestore
            .collection('projects')
            .where('memberIds', arrayContains: currentUser.uid)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
          results.addAll(
            snap.docs.map(
              (doc) => SearchResult.fromFirestore(doc, SearchResultType.project),
            ),
          );
        }).catchError((_) {}),
      );
    }

    // 3. Search Groups
    if (filterType == null || filterType == SearchResultType.group) {
      searchFutures.add(
        _firestore
            .collection('groups')
            .where('memberIds', arrayContains: currentUser.uid)
            .where('name', isGreaterThanOrEqualTo: trimmedQuery)
            .where('name', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
          results.addAll(
            snap.docs.map(
              (doc) => SearchResult.fromFirestore(doc, SearchResultType.group),
            ),
          );
        }).catchError((e) {
          print('Error searching groups: $e');
        }),
      );
    }

    // 4. Search Tasks (Member of Project OR Creator OR Assignee)
    if (filterType == null || filterType == SearchResultType.task) {
      // Step 4a: Get all project IDs where user is a member
      final projectsSnap = await _firestore
          .collection('projects')
          .where('memberIds', arrayContains: currentUser.uid)
          .limit(30) // Firestore whereIn limit
          .get();
      
      final projectIds = projectsSnap.docs.map((doc) => doc.id).toList();

      if (projectIds.isNotEmpty) {
        searchFutures.add(
          _firestore
              .collectionGroup('tasks')
              .where('projectId', whereIn: projectIds)
              .where('title', isGreaterThanOrEqualTo: trimmedQuery)
              .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
              .limit(20)
              .get()
              .then((snap) {
            results.addAll(
              snap.docs.map(
                (doc) => SearchResult.fromFirestore(doc, SearchResultType.task),
              ),
            );
          }).catchError((e) {
            print('Error searching project tasks: $e');
          }),
        );
      }

      // Query 1: Tasks created by user (in case some are not in projects or cross-project logic differs)
      searchFutures.add(
        _firestore
            .collectionGroup('tasks')
            .where('creatorId', isEqualTo: currentUser.uid)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
          results.addAll(
            snap.docs.map(
              (doc) => SearchResult.fromFirestore(doc, SearchResultType.task),
            ),
          );
        }).catchError((e) {
          print('Error searching created tasks: $e');
        }),
      );

      // Query 2: Tasks assigned to user
      searchFutures.add(
        _firestore
            .collectionGroup('tasks')
            .where('assigneeIds', arrayContains: currentUser.uid) // Updated field name (assigneeIds)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
          results.addAll(
            snap.docs.map(
              (doc) => SearchResult.fromFirestore(doc, SearchResultType.task),
            ),
          );
        }).catchError((e) {
          print('Error searching assigned tasks: $e');
        }),
      );
    }

    await Future.wait(searchFutures);

    // Simple de-duplication based on ID (especially for tasks where user might be both creator and assignee)
    final uniqueResults = <String, SearchResult>{};
    for (var res in results) {
      uniqueResults[res.id] = res;
    }

    return uniqueResults.values.toList();
  }
}

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(),
);
