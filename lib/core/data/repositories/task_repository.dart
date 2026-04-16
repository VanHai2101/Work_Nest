import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/domain/entities/index.dart';

class TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _tasksCollection = 'tasks';

  /// Get all tasks for a project
  Stream<List<TaskEntity>> getProjectTasks(String projectId) {
    return _firestore
        .collection('projects')
        .doc(projectId)
        .collection(_tasksCollection)
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _parseTaskEntity(doc)).toList());
  }

  /// Get user assigned tasks across ALL projects
  Stream<List<TaskEntity>> getUserAssignedTasks(String userId) {
    return _firestore
        .collectionGroup(_tasksCollection)
        .where('assigneeIds', arrayContains: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _parseTaskEntity(doc)).toList());
  }

  /// Get task by ID (needs projectId or collectionGroup)
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
        // Fallback to collectionGroup if projectId is unknown
        final query = await _firestore
            .collectionGroup(_tasksCollection)
            .where(FieldPath.documentId, isEqualTo: taskId)
            .limit(1)
            .get();
        if (query.docs.isEmpty) return null;
        doc = query.docs.first;
      }
      
      if (!doc.exists) return null;
      return _parseTaskEntity(doc);
    } catch (e) {
      // Re-throwing or logging instead of print
      return null;
    }
  }

  /// Create task
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
    try {
      final docRef = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection(_tasksCollection)
          .add({
        'title': title,
        'description': description,
        'creatorId': creatorId,
        'projectId': projectId,
        'dueDate': dueDate,
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
    } catch (e) {
      rethrow;
    }
  }

  /// Update task
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
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (dueDate != null) updates['dueDate'] = dueDate;
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
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, String projectId, bool completed) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection(_tasksCollection)
          .doc(taskId)
          .update({
        'completed': completed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete task
  Future<void> deleteTask(String taskId, String projectId) async {
    try {
      await _firestore
          .collection('projects')
          .doc(projectId)
          .collection(_tasksCollection)
          .doc(taskId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  TaskEntity _parseTaskEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskEntity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorId: data['creatorId'] ?? '',
      projectId: data['projectId'] ?? '',
      assigneeIds: List<String>.from(data['assigneeIds'] ?? []),
      completed: data['completed'] ?? false,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueTime: data['dueTime'] ?? '09:00',
      order: (data['order'] as Timestamp?)?.toDate().millisecondsSinceEpoch ?? 0,
      priority: data['priority'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      attachments: List<String>.from(data['attachments'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
