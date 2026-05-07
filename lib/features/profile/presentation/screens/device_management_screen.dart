import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/index.dart';
import '../../../auth/domain/entities/user_device.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/providers/device_providers.dart';

class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(userDevicesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Quản lý thiết bị',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: devicesAsync.when(
        data: (devices) => _buildDeviceList(context, ref, devices),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, WidgetRef ref, List<UserDevice> devices) {
    if (devices.isEmpty) {
      return const Center(child: Text('Không tìm thấy thiết bị nào'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: devices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _DeviceCard(device: device);
      },
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final UserDevice device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastActiveStr = DateFormat('HH:mm, dd/MM/yyyy').format(device.lastActive);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: device.isCurrent ? AppColors.darkAccent.withOpacity(0.3) : AppColors.border,
          width: device.isCurrent ? 1.5 : 1,
        ),
        boxShadow: device.isCurrent ? [
          BoxShadow(
            color: AppColors.darkAccent.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getPlatformColor(device.platform).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPlatformIcon(device.platform),
              color: _getPlatformColor(device.platform),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.deviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (device.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          'HIỆN TẠI',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${device.osVersion} • $lastActiveStr',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!device.isCurrent)
            IconButton(
              icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              onPressed: () => _confirmRemove(context, ref),
            ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất thiết bị?'),
        content: Text('Bạn có chắc chắn muốn đăng xuất khỏi ${device.deviceName} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final user = ref.read(currentUserProvider).value;
              if (user != null) {
                await ref.read(deviceRepositoryProvider).removeDevice(user.uid, device.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Đăng xuất', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'android': return Icons.android_rounded;
      case 'ios': return Icons.apple_rounded;
      case 'windows': return Icons.window_rounded;
      case 'web': return Icons.language_rounded;
      default: return Icons.devices_rounded;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'android': return Colors.green;
      case 'ios': return Colors.black87;
      case 'windows': return Colors.blue;
      case 'web': return Colors.orange;
      default: return AppColors.darkAccent;
    }
  }
}
