import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/search_result_entity.dart';
import '../../domain/repositories/search_repository.dart';

class SearchResultModel extends SearchResultEntity {
  SearchResultModel({
    required super.id,
    required super.title,
    super.subtitle,
    super.photoURL,
    required super.type,
    required super.rawData,
  });

  factory SearchResultModel.fromFirestore(
    DocumentSnapshot doc,
    SearchResultType type,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    if (type == SearchResultType.user) {
      return SearchResultModel(
        id: doc.id,
        title: data['displayName'] ?? 'Người dùng không tên',
        subtitle: data['plan'] ?? 'Gói miễn phí',
        photoURL: data['photoURL'],
        type: type,
        rawData: data,
      );
    } else if (type == SearchResultType.project) {
      return SearchResultModel(
        id: doc.id,
        title: data['title'] ?? 'Dự án không tên',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    } else if (type == SearchResultType.group) {
      return SearchResultModel(
        id: doc.id,
        title: data['name'] ?? 'Nhóm không tên',
        subtitle: data['description'],
        photoURL: data['photoURL'],
        type: type,
        rawData: data,
      );
    } else {
      // Task
      return SearchResultModel(
        id: doc.id,
        title: data['title'] ?? 'Công việc không tên',
        subtitle: data['description'],
        type: type,
        rawData: data,
      );
    }
  }
}

class FirebaseSearchRepository implements ISearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<SearchResultEntity>> searchGlobal(
    String query, {
    SearchResultType? filterType,
  }) async {
    if (query.isEmpty) return [];

    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 2) return [];

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final results = <SearchResultEntity>[];

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
                  (doc) =>
                      SearchResultModel.fromFirestore(doc, SearchResultType.user),
                ),
              );
            })
            .catchError((_) {}),
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
                  (doc) =>
                      SearchResultModel.fromFirestore(doc, SearchResultType.project),
                ),
              );
            })
            .catchError((_) {}),
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
                  (doc) =>
                      SearchResultModel.fromFirestore(doc, SearchResultType.group),
                ),
              );
            })
            .catchError((_) {}),
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
                    (doc) =>
                        SearchResultModel.fromFirestore(doc, SearchResultType.task),
                  ),
                );
              })
              .catchError((_) {}),
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
                  (doc) =>
                      SearchResultModel.fromFirestore(doc, SearchResultType.task),
                ),
              );
            })
            .catchError((_) {}),
      );

      // Query 2: Tasks assigned to user
      searchFutures.add(
        _firestore
            .collectionGroup('tasks')
            .where(
              'assigneeIds',
              arrayContains: currentUser.uid,
            ) // Updated field name (assigneeIds)
            .where('title', isGreaterThanOrEqualTo: trimmedQuery)
            .where('title', isLessThanOrEqualTo: '$trimmedQuery\uf8ff')
            .limit(10)
            .get()
            .then((snap) {
              results.addAll(
                snap.docs.map(
                  (doc) =>
                      SearchResultModel.fromFirestore(doc, SearchResultType.task),
                ),
              );
            })
            .catchError((_) {}),
      );
    }

    await Future.wait(searchFutures);

    // Simple de-duplication based on ID (especially for tasks where user might be both creator and assignee)
    final uniqueResults = <String, SearchResultEntity>{};
    for (var res in results) {
      uniqueResults[res.id] = res;
    }

    return uniqueResults.values.toList();
  }
}
