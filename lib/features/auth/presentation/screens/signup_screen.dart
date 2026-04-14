import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bubble_background_wrapper.dart';
import '../../../../core/domain/states/operation_state.dart';
import '../../application/notifiers/auth_notifier.dart';

// Chuyển từ StatelessWidget thành ConsumerStatefulWidget để dùng Riverpod và Controller
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // 1. Khai báo các Controller để lấy dữ liệu từ ô nhập
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. Lắng nghe trạng thái của AuthNotifier
    final authState = ref.watch(authNotifierProvider);

    // 3. Xử lý các sự kiện (thành công hoặc lỗi)
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is OperationSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
        Navigator.pop(context); // Quay về màn hình cũ hoặc chuyển trang
      } else if (next is OperationFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: BubbleBackgroundWrapper(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Your',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Panel nhập liệu
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Truyền Controller vào các ô nhập
                        _buildTextField(
                          'Full Name',
                          'Tên của bạn',
                          false,
                          _nameController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          'Email',
                          'example@gmail.com',
                          false,
                          _emailController,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          'Password',
                          '*********',
                          true,
                          _passwordController,
                        ),
                        const SizedBox(height: 30),

                        // Nút SIGN UP
                        _buildGradientButton(
                          context,
                          authState is OperationLoading
                              ? 'LOGGING...'
                              : 'SIGN UP',
                          () {
                            if (authState is! OperationLoading) {
                              // 4. Gọi hàm signUp từ Notifier
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .signUp(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _nameController.text.trim(),
                                  );
                            }
                          },
                        ),
                        // ... (phần nút Sign in bên dưới giữ nguyên)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sửa lại hàm _buildTextField để nhận thêm controller
  Widget _buildTextField(
    String label,
    String hint,
    bool isPassword,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B0021),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: controller, // Gắn controller tại đây
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: Icon(
              isPassword ? Icons.visibility_off : Icons.check,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B0021), Color(0xFF33000C)],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
