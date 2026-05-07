import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_device.dart';
import '../../data/repositories/firebase_device_repository.dart';
import 'auth_providers.dart';

final deviceRepositoryProvider = Provider<FirebaseDeviceRepository>((ref) {
  return FirebaseDeviceRepository();
});

final userDevicesProvider = StreamProvider<List<UserDevice>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(deviceRepositoryProvider).watchDevices(user.uid);
});

/// Khởi tạo thiết bị hiện tại khi người dùng đăng nhập
final deviceInitializerProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) {
    debugPrint('DeviceInitializer: No user logged in');
    return;
  }

  debugPrint('DeviceInitializer: User logged in, registering device...');
  final repo = ref.read(deviceRepositoryProvider);
  repo.getDeviceInfo().then((device) {
    debugPrint('DeviceInitializer: Device info retrieved: ${device.deviceName}');
    repo.updateDevice(user.uid, device).then((_) {
      debugPrint('DeviceInitializer: Device registered successfully');
    }).catchError((e) {
      debugPrint('DeviceInitializer: Error registering device: $e');
    });
  });
});
