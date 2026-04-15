import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../features/auth/presentation/screens/index.dart';
import '../features/home/presentation/screens/main_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );
      case AppRoutes.calendar:
        return MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy màn hình: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
