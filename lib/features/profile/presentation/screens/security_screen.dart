import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bảo mật', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSecurityOption(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Thay đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn định kỳ',
          ),
          _buildSecurityOption(
            context,
            icon: Icons.phonelink_lock_rounded,
            title: 'Xác thực 2 yếu tố (2FA)',
            subtitle: 'Thêm lớp bảo vệ cho tài khoản',
            isImplemented: false,
          ),
          _buildSecurityOption(
            context,
            icon: Icons.devices_rounded,
            title: 'Các thiết bị đã đăng nhập',
            subtitle: 'Quản lý phiên đăng nhập của bạn',
          ),
          const SizedBox(height: 32),
          Text(
            'HÀNH ĐỘNG NGUY HIỂM',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildSecurityOption(
            context,
            icon: Icons.delete_forever_rounded,
            title: 'Xóa tài khoản',
            subtitle: 'Vĩnh viễn xóa dữ liệu của bạn',
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isImplemented = true,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isImplemented ? 'Chức năng đang được cập nhật' : 'Tính năng này đang được phát triển')),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? AppColors.darkAccent).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? AppColors.darkAccent, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black12, size: 14),
      ),
    );
  }
}
