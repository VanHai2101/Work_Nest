class CallEntity {
  final String id;
  final String callerUid;
  final String calleeUid;
  final String status;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic>? offer;
  final Map<String, dynamic>? answer;
  final DateTime? endedAt;

  CallEntity({
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
}
