import 'package:cloud_firestore/cloud_firestore.dart';

class UserDevice {
  final String id;
  final String deviceName;
  final String deviceModel;
  final String osVersion;
  final String platform; // 'android', 'ios', 'web', 'windows', etc.
  final DateTime lastActive;
  final bool isCurrent;

  UserDevice({
    required this.id,
    required this.deviceName,
    required this.deviceModel,
    required this.osVersion,
    required this.platform,
    required this.lastActive,
    this.isCurrent = false,
  });

  factory UserDevice.fromMap(String id, Map<String, dynamic> map, {String? currentDeviceId}) {
    return UserDevice(
      id: id,
      deviceName: map['deviceName'] ?? 'Unknown Device',
      deviceModel: map['deviceModel'] ?? '',
      osVersion: map['osVersion'] ?? '',
      platform: map['platform'] ?? 'unknown',
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCurrent: id == currentDeviceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'platform': platform,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }
}
