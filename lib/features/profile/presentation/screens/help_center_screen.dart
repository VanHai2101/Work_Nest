import 'package:flutter/material.dart';
import '../../../../core/theme/index.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trung tâm trợ giúp',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchBox(),
            const SizedBox(height: 24),
            _buildFAQSection(),
            const SizedBox(height: 32),
            _buildContactSupport(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm hướng dẫn...',
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CÂU HỎI THƯỜNG GẶP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem('Làm thế nào để tạo dự án mới?'),
        _buildFAQItem('Cách mời thành viên vào nhóm?'),
        _buildFAQItem('Quản lý thông báo như thế nào?'),
        _buildFAQItem('Chính sách bảo mật dữ liệu?'),
      ],
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black26,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkAccent, AppColors.darkAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkAccent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.headset_mic_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Bạn vẫn cần hỗ trợ?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đội ngũ của chúng tôi luôn sẵn sàng giúp đỡ bạn 24/7.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
