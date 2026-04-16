/// Domain repository interface for Video/Audio calls.
library;

import '../entities/index.dart';
import '../../data/models/ice_candidate_model.dart';

abstract class CallRepository {
  /// Stream of call updates for a specific call.
  Stream<CallEntity?> watchCall(String callId);

  /// Stream of incoming calls for the current user.
  Stream<CallEntity?> watchIncomingCalls(String userId);

  /// Start a new call.
  Future<String> startCall(CallEntity call);

  /// Accept an incoming call by providing the answer SDP.
  Future<void> acceptCall(String callId, Map<String, dynamic> answer);

  /// End a call.
  Future<void> endCall(String callId, {CallStatus status = CallStatus.ended});

  /// Reject an incoming call.
  Future<void> rejectCall(String callId);

  /// Add an ICE candidate to the signaling documentation.
  Future<void> addIceCandidate(String callId, IceCandidateModel candidate, bool isCaller);

  /// Listen for ICE candidates from the remote side.
  Stream<List<IceCandidateModel>> watchIceCandidates(String callId, bool isFromCaller);
}
