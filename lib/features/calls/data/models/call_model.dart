/// Call model implementation for Firestore data layer.
///
/// This model handles serialization/deserialization of call data
/// used for WebRTC signaling.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_nest/core/utils/parser.dart';
import '../../domain/entities/call_entity.dart';

class CallModel {
  final String id;
  final String callerUid;
  final String calleeUid;
  final String status; // ringing, accepted, ended, rejected, missed
  final String type; // video, audio
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final Timestamp createdAt;
  final Timestamp? endedAt;

  CallModel({
    required this.id,
    required this.callerUid,
    required this.calleeUid,
    required this.status,
    required this.type,
    this.offer,
    this.answer,
    required this.createdAt,
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
      offer: json['offer'] as Map<String, dynamic>?,
      answer: json['answer'] as Map<String, dynamic>?,
      createdAt: Parser.parseTimestamp(json['createdAt']),
      endedAt: json['endedAt'] != null ? Parser.parseTimestamp(json['endedAt']) : null,
    );
  }

  factory CallModel.fromEntity(CallEntity entity) => CallModel(
        id: entity.id,
        callerUid: entity.callerUid,
        calleeUid: entity.calleeUid,
        status: entity.status.name,
        type: entity.type.name,
        offer: entity.offer,
        answer: entity.answer,
        createdAt: Timestamp.fromDate(entity.createdAt),
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
        'offer': offer,
        'answer': answer,
        'createdAt': createdAt,
        'endedAt': endedAt,
      };

  CallEntity toEntity() => CallEntity(
        id: id,
        callerUid: callerUid,
        calleeUid: calleeUid,
        status: CallStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => CallStatus.ringing,
        ),
        type: CallType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => CallType.video,
        ),
        offer: offer,
        answer: answer,
        createdAt: createdAt.toDate(),
        endedAt: endedAt?.toDate(),
      );
}
