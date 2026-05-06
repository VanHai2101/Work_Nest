import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user_device.dart';
import '../../domain/repositories/device_repository.dart';

class FirebaseDeviceRepository implements DeviceRepository {
  final FirebaseFirestore _firestore;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _deviceUuidKey = 'user_device_uuid';

  FirebaseDeviceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<UserDevice>> watchDevices(String userId) async* {
    final currentId = await getCurrentDeviceId();
    yield* _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .orderBy('lastActive', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserDevice.fromMap(doc.id, doc.data(), currentDeviceId: currentId))
            .toList());
  }

  @override
  Future<void> updateDevice(String userId, UserDevice device) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(device.id)
        .set(device.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> removeDevice(String userId, String deviceId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }

  @override
  Future<String> getCurrentDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_deviceUuidKey);
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_deviceUuidKey, uuid);
    }
    return uuid;
  }

  Future<UserDevice> getDeviceInfo() async {
    final id = await getCurrentDeviceId();
    String deviceName = 'Unknown Device';
    String deviceModel = '';
    String osVersion = '';
    String platform = 'unknown';

    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      deviceName = webInfo.browserName.name;
      deviceModel = webInfo.userAgent ?? '';
      platform = 'web';
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceName = '${androidInfo.brand} ${androidInfo.model}';
      deviceModel = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
      platform = 'android';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceName = iosInfo.name;
      deviceModel = iosInfo.model;
      osVersion = 'iOS ${iosInfo.systemVersion}';
      platform = 'ios';
    } else if (Platform.isWindows) {
      final winInfo = await _deviceInfo.windowsInfo;
      deviceName = winInfo.computerName;
      osVersion = 'Windows ${winInfo.releaseId}';
      platform = 'windows';
    }

    return UserDevice(
      id: id,
      deviceName: deviceName,
      deviceModel: deviceModel,
      osVersion: osVersion,
      platform: platform,
      lastActive: DateTime.now(),
    );
  }
}
