import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../bubble_background_wrapper.dart';
import '../../../../core/domain/states/operation_state.dart';
import '../../application/notifiers/auth_notifier.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 1. Khai báo Controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // 2. Lắng nghe trạng thái đăng nhập
    ref.listen(authNotifierProvider, (previous, next) {
      if (next is OperationSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));
        // Ở đây bạn có thể Navigator.pushReplacement tới màn hình Home
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
                          // UI title giữ nguyên...
                          Text(
                            'Hello',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            'Sign in!',
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
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(30, 50, 30, 40),
                    child: Column(
                      children: [
                        // 3. Gắn Controller vào ô nhập
                        _buildTextField(
                          'Email',
                          'example@gmail.com',
                          true,
                          _emailController,
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                          'Password',
                          '*********',
                          false,
                          _passwordController,
                        ),

                        const SizedBox(height: 30),

                        // 4. Nút SIGN IN
                        _buildGradientButton(
                          context,
                          authState is OperationLoading
                              ? 'SIGNING IN...'
                              : 'SIGN IN',
                          () {
                            if (authState is! OperationLoading) {
                              ref
                                  .read(authNotifierProvider.notifier)
                                  .signIn(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                            }
                          },
                        ),
                        // ... (Phần Don't have account giữ nguyên)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Back Button...
          ],
        ),
      ),
    );
  }

  // Hàm helper sửa lại để nhận controller
  Widget _buildTextField(
    String label,
    String hint,
    bool isEmail,
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
          controller: controller,
          obscureText: !isEmail,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: Icon(
              isEmail ? Icons.check : Icons.visibility_off,
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
