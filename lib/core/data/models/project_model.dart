import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/project_entity.dart';
import 'package:work_nest/core/utils/parser.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final String status;
  final double progress;
  final Timestamp dueDate;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? color;
  final List<String> tags;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.color,
    this.tags = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return ProjectModel.empty();
    return ProjectModel(
      id: id ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      memberIds: Parser.parseStringList(json['memberIds']),
      status: json['status'] as String? ?? 'ongoing',
      progress: Parser.parseDouble(json['progress']),
      dueDate: Parser.parseTimestamp(json['dueDate']),
      createdAt: Parser.parseTimestamp(json['createdAt']),
      updatedAt: Parser.parseTimestamp(json['updatedAt']),
      color: json['color'] as String?,
      tags: Parser.parseStringList(json['tags']),
    );
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) => ProjectModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    ownerId: entity.ownerId,
    memberIds: entity.memberIds,
    status: entity.status,
    progress: entity.progress,
    dueDate: Timestamp.fromDate(entity.dueDate),
    createdAt: Timestamp.fromDate(entity.createdAt),
    updatedAt: Timestamp.fromDate(entity.updatedAt),
    color: entity.color,
    tags: entity.tags,
  );

  factory ProjectModel.empty() => ProjectModel(
    id: '',
    title: '',
    description: '',
    ownerId: '',
    memberIds: [],
    status: 'ongoing',
    progress: 0.0,
    dueDate: Timestamp.now(),
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'status': status,
    'progress': progress,
    'dueDate': dueDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'color': color,
    'tags': tags,
  };

  ProjectEntity toEntity() => ProjectEntity(
    id: id,
    title: title,
    description: description,
    ownerId: ownerId,
    memberIds: memberIds,
    status: status,
    progress: progress,
    dueDate: dueDate.toDate(),
    createdAt: createdAt.toDate(),
    updatedAt: updatedAt.toDate(),
    color: color,
    tags: tags,
  );

  static List<ProjectModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];

  static List<ProjectEntity> toEntityList(List<ProjectModel> models) =>
      models.map((m) => m.toEntity()).toList();
}
