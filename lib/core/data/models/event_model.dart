import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/event_entity.dart';
import 'package:work_nest/core/utils/parser.dart';

class EventModel {
  final String id;
  final String title;
  final String? description;
  final Timestamp date;
  final String time;
  final String color;
  final String? taskId;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? repeat;
  final String? reminder;
  final String? location;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    required this.color,
    this.taskId,
    required this.createdAt,
    required this.updatedAt,
    this.repeat,
    this.reminder,
    this.location,
  });

  factory EventModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return EventModel.empty();
    return EventModel(
      id: id ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      date: Parser.parseTimestamp(json['date']),
      time: json['time'] as String? ?? '',
      color: json['color'] as String? ?? '',
      taskId: json['taskId'] as String?,
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
      repeat: json['repeat'] as String?,
      reminder: json['reminder'] as String?,
      location: json['location'] as String?,
    );
  }

  factory EventModel.fromEntity(EventEntity entity) => EventModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    date: Timestamp.fromDate(entity.date),
    time: entity.time,
    color: entity.color,
    taskId: entity.taskId,
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
    repeat: entity.repeat,
    reminder: entity.reminder,
    location: entity.location,
  );

  factory EventModel.empty() => EventModel(
    id: '',
    title: '',
    date: Timestamp.now(),
    time: '',
    color: '',
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'date': date,
    'time': time,
    'color': color,
    'taskId': taskId,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'repeat': repeat,
    'reminder': reminder,
    'location': location,
  };

  EventEntity toEntity() => EventEntity(
    id: id,
    title: title,
    description: description,
    date: date.toDate(),
    time: time,
    color: color,
    taskId: taskId,
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
    repeat: repeat,
    reminder: reminder,
    location: location,
  );

  static List<EventModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
}
