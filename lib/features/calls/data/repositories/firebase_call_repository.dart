/// Firebase implementation of the CallRepository for WebRTC signaling.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class FirebaseCallRepository implements CallRepository {
  final FirebaseFirestore _firestore;

  FirebaseCallRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<CallEntity?> watchCall(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return CallModel.fromJson(snapshot.data(), id: snapshot.id).toEntity();
    });
  }

  @override
  Stream<CallEntity?> watchIncomingCalls(String userId) {
    return _firestore
        .collection('calls')
        .where('calleeUid', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return CallModel.fromJson(doc.data(), id: doc.id).toEntity();
    });
  }

  @override
  Future<String> startCall(CallEntity call) async {
    final model = CallModel.fromEntity(call);
    final docRef = await _firestore.collection('calls').add(model.toJson());
    return docRef.id;
  }

  @override
  Future<void> acceptCall(String callId, Map<String, dynamic> answer) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'accepted',
      'answer': answer,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> endCall(String callId, {CallStatus status = CallStatus.ended}) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': status.name,
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectCall(String callId) async {
    await endCall(callId, status: CallStatus.rejected);
  }

  @override
  Future<void> addIceCandidate(String callId, IceCandidateModel candidate, bool isCaller) async {
    final subcollection = isCaller ? 'callerCandidates' : 'calleeCandidates';
    await _firestore
        .collection('calls')
        .doc(callId)
        .collection(subcollection)
        .add(candidate.toJson());
  }

  @override
  Stream<List<IceCandidateModel>> watchIceCandidates(String callId, bool isFromCaller) {
    final subcollection = isFromCaller ? 'callerCandidates' : 'calleeCandidates';
    return _firestore
        .collection('calls')
        .doc(callId)
        .collection(subcollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IceCandidateModel.fromJson(doc.data()))
            .toList());
  }
}
