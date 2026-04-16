import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/domain/entities/index.dart';
import 'package:work_nest/core/utils/index.dart';

class CallModel {
  final String id;
  final String callerUid;
  final String calleeUid;
  final String status;
  final String type;
  final Timestamp createdAt;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final Timestamp? endedAt;

  CallModel({
    required this.id,
    required this.callerUid,
    required this.calleeUid,
    required this.status,
    required this.type,
    required this.createdAt,
    this.offer,
    this.answer,
    this.endedAt,
  });

  factory CallModel.fromJson(Map<String, dynamic>? json, {String? id}) {
    if (json == null) return CallModel.empty();
    return CallModel(
      id: id ?? '',
      callerUid: json['callerUid'] as String? ?? '',
      calleeUid: json['calleeUid'] as String? ?? '',
      status: json['status'] as String? ?? 'ringing',
      type: json['type'] as String? ?? 'video',
      createdAt: Parser.parseTimestamp(json['createdAt']),
      offer: json['offer'] as Map<String, dynamic>?,
      answer: json['answer'] as Map<String, dynamic>?,
      endedAt: json['endedAt'] != null ? Parser.parseTimestamp(json['endedAt']) : null,
    );
  }

  factory CallModel.fromEntity(CallEntity entity) => CallModel(
    id: entity.id,
    callerUid: entity.callerUid,
    calleeUid: entity.calleeUid,
    status: entity.status,
    type: entity.type,
    createdAt: Timestamp.fromDate(entity.createdAt),
    offer: entity.offer,
    answer: entity.answer,
    endedAt: entity.endedAt != null ? Timestamp.fromDate(entity.endedAt!) : null,
  );

  factory CallModel.empty() => CallModel(
    id: '',
    callerUid: '',
    calleeUid: '',
    status: 'ringing',
    type: 'video',
    createdAt: Timestamp.now(),
  );

  Map<String, dynamic> toJson() => {
    'callerUid': callerUid,
    'calleeUid': calleeUid,
    'status': status,
    'type': type,
    'createdAt': createdAt,
    'offer': offer,
    'answer': answer,
    'endedAt': endedAt,
  };

  CallEntity toEntity() => CallEntity(
    id: id,
    callerUid: callerUid,
    calleeUid: calleeUid,
    status: status,
    type: type,
    createdAt: createdAt.toDate(),
    offer: offer,
    answer: answer,
    endedAt: endedAt?.toDate(),
  );

  static List<CallModel> fromJsonList(List<dynamic>? jsonList) =>
      jsonList?.map((e) => CallModel.fromJson(e as Map<String, dynamic>)).toList() ?? [];
}
