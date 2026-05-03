import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/permission_service.dart';
import '../services/local_storage_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
