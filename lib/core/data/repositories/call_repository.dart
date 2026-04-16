import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/index.dart';

class CallRepository {
  final FirebaseFirestore _firestore;

  CallRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Create call
  Future<Call> createCall({
    required String callerUid,
    required String calleeUid,
    required CallType type,
  }) async {
    final callRef = _firestore.collection('calls').doc();

    final call = Call(
      id: callRef.id,
      callerUid: callerUid,
      calleeUid: calleeUid,
      status: CallStatus.ringing,
      type: type,
      createdAt: DateTime.now(),
    );

    await callRef.set(call.toMap());
    return call;
  }

  // Get call
  Stream<Call?> getCall(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Call.fromMap(doc.data()!, doc.id);
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
