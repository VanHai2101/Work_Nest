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
    print('DeviceInitializer: No user logged in');
    return;
  }

  print('DeviceInitializer: User logged in, registering device...');
  final repo = ref.read(deviceRepositoryProvider);
  repo.getDeviceInfo().then((device) {
    print('DeviceInitializer: Device info retrieved: ${device.deviceName}');
    repo.updateDevice(user.uid, device).then((_) {
      print('DeviceInitializer: Device registered successfully');
    }).catchError((e) {
      print('DeviceInitializer: Error registering device: $e');
    });
  });
});
