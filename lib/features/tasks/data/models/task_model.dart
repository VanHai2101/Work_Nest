import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/utils/parser.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final List<String> assigneeIds;
  final String creatorId;
  final bool completed;
  final Timestamp dueDate;
  final String dueTime;
  final String projectId;
  final int order;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String priority;
  final List<String> tags;
  final List<String> attachments;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assigneeIds,
    required this.creatorId,
    required this.completed,
    required this.dueDate,
    required this.dueTime,
    required this.projectId,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.priority,
    this.tags = const [],
    this.attachments = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return TaskModel.empty();
    return TaskModel(
      id: id ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      assigneeIds: Parser.parseStringList(json['assigneeIds']),
      creatorId: json['creatorId'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      dueDate: Parser.parseTimestamp(json['dueDate']),
      dueTime: json['dueTime'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      order: Parser.parseInt(json['order']),
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
      priority: json['priority'] as String? ?? 'medium',
      tags: Parser.parseStringList(json['tags']),
      attachments: Parser.parseStringList(json['attachments']),
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    assigneeIds: entity.assigneeIds,
    creatorId: entity.creatorId,
    completed: entity.completed,
    dueDate: Timestamp.fromDate(entity.dueDate),
    dueTime: entity.dueTime,
    projectId: entity.projectId,
    order: entity.order,
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
    priority: entity.priority,
    tags: entity.tags,
    attachments: entity.attachments,
  );

  factory TaskModel.empty() => TaskModel(
    id: '',
    title: '',
    description: '',
    assigneeIds: [],
    creatorId: '',
    completed: false,
    dueDate: Timestamp.now(),
    dueTime: '',
    projectId: '',
    order: 0,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
    priority: 'medium',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'assigneeIds': assigneeIds,
    'creatorId': creatorId,
    'completed': completed,
    'dueDate': dueDate,
    'dueTime': dueTime,
    'projectId': projectId,
    'order': order,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'priority': priority,
    'tags': tags,
    'attachments': attachments,
  };

  TaskEntity toEntity() => TaskEntity(
    id: id,
    title: title,
    description: description,
    assigneeIds: assigneeIds,
    creatorId: creatorId,
    completed: completed,
    dueDate: dueDate.toDate(),
    dueTime: dueTime,
    projectId: projectId,
    order: order,
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
    priority: priority,
    tags: tags,
    attachments: attachments,
  );

  static List<TaskModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  static List<TaskEntity> toEntityList(List<TaskModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
