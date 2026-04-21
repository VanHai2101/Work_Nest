import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Về WorkNest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.darkAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.work_rounded,
                color: AppColors.darkAccent,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'WorkNest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 48),
            _buildInfoTile('Chính sách bảo mật'),
            _buildInfoTile('Điều khoản dịch vụ'),
            _buildInfoTile('Giấy phép mã nguồn mở'),
            const SizedBox(height: 48),
            Text(
              '© 2024 WorkNest Inc. All rights reserved.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.black12,
          size: 14,
        ),
        onTap: () {},
      ),
    );
  }
}
