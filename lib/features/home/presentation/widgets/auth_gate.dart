import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/features/auth/presentation/screens/welcome_screen.dart';
import 'package:work_nest/features/auth/application/providers/auth_providers.dart';
import 'package:work_nest/features/home/presentation/screens/main_screen.dart';

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
          Scaffold(body: Center(child: Text('Lỗi kết nối: $e'))),
    );
  }
}
