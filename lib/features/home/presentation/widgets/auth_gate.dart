import 'package:work_nest/features/auth/presentation/providers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/providers/index.dart';
import 'package:work_nest/features/auth/presentation/screens/index.dart';
import 'package:work_nest/features/home/presentation/screens/index.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainScreen();
        }
        return const WelcomeScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) =>
          const Scaffold(body: Center(child: Text('Lỗi kết nối. Vui lòng khởi động lại ứng dụng.'))),
    );
  }
}
