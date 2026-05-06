import '../entities/user_device.dart';

abstract class DeviceRepository {
  Stream<List<UserDevice>> watchDevices(String userId);
  Future<void> updateDevice(String userId, UserDevice device);
  Future<void> removeDevice(String userId, String deviceId);
  Future<String> getCurrentDeviceId();
}
