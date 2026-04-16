import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // Truy vấn tất cả các task thuộc về người dùng hiện tại hoặc toàn bộ project
    return _firestore
        .collectionGroup('tasks')
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .asyncMap((snapshot) async {
      
      // Dùng Map để cache màu của project lại, tránh gọi API nhiều lần cho cùng 1 project
      Map<String, Color> projectColors = {};
      List<CalendarEvent> events = [];

      for (var doc in snapshot.docs) {
        final task = TaskModel.fromJson(doc.data(), id: doc.id);
        
        Color eventColor = AppColors.accent; // Màu mặc định
        if (task.projectId.isNotEmpty) {
          if (!projectColors.containsKey(task.projectId)) {
            // Lấy thông tin Project của task này từ Firebase để lấy màu
            final projectDoc = await _firestore.collection('projects').doc(task.projectId).get();
            final colorData = projectDoc.data()?['color'] as String?;
            projectColors[task.projectId] = _parseColor(colorData);
          }
          eventColor = projectColors[task.projectId]!;
        }

        events.add(CalendarEvent(
          id: task.id,
          title: task.title,
          description: task.description,
          startTime: task.dueDate.toDate(),
          // Tạm gán endTime bằng startTime + 1 tiếng do Task chỉ có dueDate
          endTime: task.dueDate.toDate().add(const Duration(hours: 1)),
          color: eventColor,
          projectId: task.projectId,
        ));
      }
      return events;
    });
  }

  @override
  Future<void> addEvent(CalendarEvent event) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Vui lòng đăng nhập để tạo task!');
    if (event.projectId == null || event.projectId!.isEmpty) {
      throw Exception('Task bắt buộc phải nằm trong một Project (projectId is null)');
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
      assigneeIds: [uid], // Tạm thời gán cho chính mình
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

final calendarRepositoryProvider = Provider<ICalendarRepository>((ref) {
  return FirebaseCalendarRepository();
});
