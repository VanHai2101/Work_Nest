/// Domain entity for Video/Audio calls.
///
/// This represents the pure business logic and UI state of a call.
library;

enum CallStatus {
  ringing,
  accepted,
  ended,
  rejected,
  missed,
}

enum CallType {
  video,
  audio,
}

class CallEntity {
  final String id;
  final String callerUid;
  final String calleeUid;
  final CallStatus status;
  final CallType type;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final DateTime createdAt;
  final DateTime? endedAt;

  CallEntity({
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

  CallEntity copyWith({
    String? id,
    String? callerUid,
    String? calleeUid,
    CallStatus? status,
    CallType? type,
    Map<String, dynamic>? offer,
    Map<String, dynamic>? answer,
    DateTime? createdAt,
    DateTime? endedAt,
  }) {
    return CallEntity(
      id: id ?? this.id,
      callerUid: callerUid ?? this.callerUid,
      calleeUid: calleeUid ?? this.calleeUid,
      status: status ?? this.status,
      type: type ?? this.type,
      offer: offer ?? this.offer,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
