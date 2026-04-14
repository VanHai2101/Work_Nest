/// ICE Candidate model for WebRTC signaling.
library;

class IceCandidateModel {
  final String candidate;
  final String sdpMid;
  final int sdpMLineIndex;

  IceCandidateModel({
    required this.candidate,
    required this.sdpMid,
    required this.sdpMLineIndex,
  });

  factory IceCandidateModel.fromJson(Map<String, dynamic> json) {
    return IceCandidateModel(
      candidate: json['candidate'] as String? ?? '',
      sdpMid: json['sdpMid'] as String? ?? '',
      sdpMLineIndex: json['sdpMLineIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex,
      };
}
