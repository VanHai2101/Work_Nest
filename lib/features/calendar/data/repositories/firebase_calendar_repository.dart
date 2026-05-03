import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../tasks/data/models/task_model.dart' show TaskModel;
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import 'package:work_nest/core/data/models/index.dart';
import 'package:work_nest/core/theme/index.dart';

class FirebaseCalendarRepository implements ICalendarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return AppColors.accent;
    String hexColor = colorString.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Thêm opacity FF mặc định nếu chỉ có 6 ký tự
    }
    return Color(int.tryParse(hexColor, radix: 16) ?? AppColors.accent.value);
  }

  @override
  Stream<List<CalendarEvent>> getEvents(DateTime start, DateTime end) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return _firestore
        .collectionGroup('tasks')
        .where('assigneeIds', arrayContains: uid)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          Map<String, Color> projectColors = {};
          List<CalendarEvent> events = [];

          for (var doc in snapshot.docs) {
            final task = TaskModel.fromJson(doc.data(), id: doc.id);
            if (task.dueDate.toDate().isBefore(start) ||
                task.dueDate.toDate().isAfter(end)) {
              continue;
            }

            Color eventColor = AppColors.accent;
            if (task.projectId.isNotEmpty) {
              if (!projectColors.containsKey(task.projectId)) {
                try {
                  final projectDoc = await _firestore
                      .collection('projects')
                      .doc(task.projectId)
                      .get();
                  final colorData = projectDoc.data()?['color'] as String?;
                  projectColors[task.projectId] = _parseColor(colorData);
                } catch (e) {
                  // Fallback to default if permission denied or project not found
                  projectColors[task.projectId] = AppColors.accent;
                }
              }
              eventColor = projectColors[task.projectId] ?? AppColors.accent;
            }

            events.add(
              CalendarEvent(
                id: task.id,
                title: task.title,
                description: task.description,
                startTime: task.dueDate.toDate(),
                endTime: task.dueDate.toDate().add(const Duration(hours: 1)),
                color: eventColor,
                projectId: task.projectId,
              ),
            );
          }
          return events;
        });
  }

  @override
  Future<void> addEvent(CalendarEvent event) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Vui lòng đăng nhập để tạo task!');
    if (event.projectId == null || event.projectId!.isEmpty) {
      throw Exception(
        'Task bắt buộc phải nằm trong một Project (projectId is null)',
      );
    }

    final docRef = _firestore
        .collection('projects')
        .doc(event.projectId)
        .collection('tasks')
        .doc(event.id);

    final task = TaskModel(
      id: event.id,
      title: event.title,
      description: event.description ?? '',
      assigneeIds: [uid],
      creatorId: uid,
      completed: false,
      dueDate: Timestamp.fromDate(event.startTime),
      dueTime: '${event.startTime.hour}:${event.startTime.minute}',
      projectId: event.projectId!,
      order: 0,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      priority: 'medium',
    );

    await docRef.set(task.toJson());
  }

  @override
  Future<void> updateEvent(CalendarEvent event) async {
    if (event.projectId == null || event.projectId!.isEmpty) {
      throw Exception('Không thể cập nhật: sự kiện thiếu projectId');
    }

    final docRef = _firestore
        .collection('projects')
        .doc(event.projectId)
        .collection('tasks')
        .doc(event.id);

    await docRef.update({
      'title': event.title,
      'description': event.description,
      'dueDate': Timestamp.fromDate(event.startTime),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteEvent(String id) async {
    throw Exception('Vui lòng truyền projectId để xóa task!');
    // Interface cũ chỉ truyền id, không truyền projectId nên không xóa dễ dàng được
  }
}

