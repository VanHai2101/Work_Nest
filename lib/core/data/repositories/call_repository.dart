import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/calls/domain/entities/call_entity.dart';
import '../../domain/models/call_model.dart' show IceCandidate; // Keep IceCandidate for now

class CallRepository {
  final FirebaseFirestore _firestore;

  CallRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create call
  Future<CallEntity> createCall({
    required String callerUid,
    required String calleeUid,
    required CallType type,
  }) async {
    final callRef = _firestore.collection('calls').doc();

    final call = CallEntity(
      id: callRef.id,
      callerUid: callerUid,
      calleeUid: calleeUid,
      status: CallStatus.ringing,
      type: type,
      createdAt: DateTime.now(),
    );

    await callRef.set({
      'callerUid': call.callerUid,
      'calleeUid': call.calleeUid,
      'status': call.status.name,
      'type': call.type.name,
      'createdAt': call.createdAt,
    });
    return call;
  }

  // Get call
  Stream<CallEntity?> getCall(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final map = doc.data()!;
        return CallEntity(
          id: doc.id,
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
      return null;
    });
  }

  // Update call status
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': status.name,
      if (status == CallStatus.ended) 'endedAt': DateTime.now(),
    });
  }

  // Set offer
  Future<void> setOffer(String callId, String offer) async {
    await _firestore.collection('calls').doc(callId).update({
      'offer': offer,
    });
  }

  // Set answer
  Future<void> setAnswer(String callId, String answer) async {
    await _firestore.collection('calls').doc(callId).update({
      'answer': answer,
    });
  }

  // Add ICE candidate
  Future<void> addCallerCandidate(String callId, IceCandidate candidate) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .collection('callerCandidates')
        .add(candidate.toMap());
  }

  Future<void> addCalleeCandidate(String callId, IceCandidate candidate) async {
    await _firestore
        .collection('calls')
        .doc(callId)
        .collection('calleeCandidates')
        .add(candidate.toMap());
  }

  // Get ICE candidates
  Stream<List<IceCandidate>> getCallerCandidates(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .collection('callerCandidates')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IceCandidate.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<IceCandidate>> getCalleeCandidates(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .collection('calleeCandidates')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => IceCandidate.fromMap(doc.data()))
          .toList();
    });
  }
}
