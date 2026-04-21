import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../models/index.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;
  final String _tasksCollection = 'tasks';

  FirebaseTaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TaskEntity>> getProjectTasks(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromJson(doc.data(), id: doc.id).toEntity()).toList());
  }

  @override
  Stream<List<TaskEntity>> getUserAssignedTasks(String userId) {
    return _firestore
        .collectionGroup(_tasksCollection)
        .where('assigneeIds', arrayContains: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TaskModel.fromJson(doc.data(), id: doc.id).toEntity()).toList());
  }

  @override
  Future<TaskEntity?> getTaskById(String taskId, {String? projectId}) async {
    try {
      DocumentSnapshot doc;
      if (projectId != null) {
        doc = await _firestore
            .collection('projects')
            .doc(projectId)
            .collection(_tasksCollection)
            .doc(taskId)
            .get();
      } else {
        final query = await _firestore
            .collectionGroup(_tasksCollection)
            .where(FieldPath.documentId, isEqualTo: taskId)
            .limit(1)
            .get();
        if (query.docs.isEmpty) return null;
        doc = query.docs.first;
      }
      
      if (!doc.exists) return null;
      return TaskModel.fromJson(doc.data() as Map<String, dynamic>?, id: doc.id).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> createTask({
    required String title,
    required String description,
    required String creatorId,
    required String projectId,
    required DateTime dueDate,
    required String dueTime,
    required List<String> assigneeIds,
    String priority = 'medium',
    List<String> tags = const [],
  }) async {
    final docRef = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .add({
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'projectId': projectId,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': dueTime,
      'assigneeIds': assigneeIds,
      'priority': priority,
      'tags': tags,
      'completed': false,
      'order': FieldValue.serverTimestamp(),
      'attachments': [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> updateTask({
    required String taskId,
    required String projectId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    List<String>? assigneeIds,
    String? priority,
    List<String>? tags,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (dueDate != null) updates['dueDate'] = Timestamp.fromDate(dueDate);
    if (dueTime != null) updates['dueTime'] = dueTime;
    if (assigneeIds != null) updates['assigneeIds'] = assigneeIds;
    if (priority != null) updates['priority'] = priority;
    if (tags != null) updates['tags'] = tags;

    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .doc(taskId)
        .update(updates);
  }

  @override
  Future<void> toggleTaskCompletion(
    String taskId,
    String projectId,
    bool completed, {
    String? taskTitle,
    String? creatorId,
  }) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .doc(taskId)
        .update({
      'completed': completed,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (completed) {
      String? resolvedCreatorId = creatorId;
      String resolvedTitle = taskTitle ?? 'A task';

      // Only fetch from Firestore if we don't already have the data
      if (resolvedCreatorId == null) {
        final doc = await _firestore
            .collection('projects')
            .doc(projectId)
            .collection(_tasksCollection)
            .doc(taskId)
            .get();
        final data = doc.data();
        resolvedCreatorId = data?['creatorId'] as String?;
        resolvedTitle = data?['title'] as String? ?? 'A task';
      }

      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final actorName = FirebaseAuth.instance.currentUser?.displayName ?? 'Someone';
      final actorPhoto = FirebaseAuth.instance.currentUser?.photoURL;

      if (resolvedCreatorId != null && resolvedCreatorId.isNotEmpty) {
        final docRef = _firestore.collection('notifications').doc();
        await docRef.set({
          'userId': resolvedCreatorId,
          'type': 'task_completed',
          'title': 'Task Completed',
          'body': '$actorName completed your task: "$resolvedTitle"',
          'actorId': currentUid ?? '',
          'actorName': actorName,
          'actorPhotoURL': actorPhoto,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'relatedEntityId': taskId,
          'relatedEntityType': 'task',
        });
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId, String projectId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .doc(taskId)
        .delete();
  }
}
