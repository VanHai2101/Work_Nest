import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event.dart';

class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    required super.color,
    super.isAllDay,
    super.projectId,
  });

  factory CalendarEventModel.fromEntity(CalendarEvent entity) {
    return CalendarEventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      color: entity.color,
      isAllDay: entity.isAllDay,
      projectId: entity.projectId,
    );
  }

  factory CalendarEventModel.fromJson(Map<String, dynamic> json, String id) {
    return CalendarEventModel(
      id: id,
      title: json['title'] as String? ?? 'Không có tiêu đề',
      description: json['description'] as String?,
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
      color: Color(json['color'] as int? ?? 0xFF4CAF50), // Mặc định xanh lá
      isAllDay: json['is_all_day'] as bool? ?? false,
      projectId: json['project_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'color': color.value,
      'is_all_day': isAllDay,
      'project_id': projectId,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
