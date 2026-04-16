enum CallStatus { ringing, accepted, ended, rejected, missed }
enum CallType { video, audio }

class Call {
  final String id;
  final String callerUid;
  final String calleeUid;
  final CallStatus status;
  final CallType type;
  final String? offer;
  final String? answer;
  final DateTime createdAt;
  final DateTime? endedAt;

  Call({
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

  Duration get duration {
    if (endedAt == null) return Duration.zero;
    return endedAt!.difference(createdAt);
  }

  factory Call.fromMap(Map<String, dynamic> map, String id) {
    return Call(
      id: id,
      callerUid: map['callerUid'] ?? '',
      calleeUid: map['calleeUid'] ?? '',
      status: CallStatus.values.byName(map['status'] ?? 'ringing'),
      type: CallType.values.byName(map['type'] ?? 'video'),
      offer: map['offer'],
      answer: map['answer'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      endedAt: map['endedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerUid': callerUid,
      'calleeUid': calleeUid,
      'status': status.name,
      'type': type.name,
      'offer': offer,
      'answer': answer,
      'createdAt': createdAt,
      'endedAt': endedAt,
    };
  }

  Call copyWith({
    String? id,
    String? callerUid,
    String? calleeUid,
    CallStatus? status,
    CallType? type,
    String? offer,
    String? answer,
    DateTime? createdAt,
    DateTime? endedAt,
  }) {
    return Call(
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

class IceCandidate {
  final String candidate;
  final String? sdpMLineIndex;
  final String? sdpMid;

  IceCandidate({
    required this.candidate,
    this.sdpMLineIndex,
    this.sdpMid,
  });

  factory IceCandidate.fromMap(Map<String, dynamic> map) {
    return IceCandidate(
      candidate: map['candidate'] ?? '',
      sdpMLineIndex: map['sdpMLineIndex'],
      sdpMid: map['sdpMid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'candidate': candidate,
      'sdpMLineIndex': sdpMLineIndex,
      'sdpMid': sdpMid,
    };
  }
}
