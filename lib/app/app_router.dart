import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/index.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/home/presentation/screens/index.dart';
import '../features/profile/presentation/screens/index.dart';
import '../features/projects/presentation/screens/index.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/tasks/presentation/screens/tasks_list_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/tasks/presentation/screens/create_task_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/profile/edit':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case '/projects':
        return MaterialPageRoute(builder: (_) => const ProjectsListScreen());
      case '/projects/create':
        return MaterialPageRoute(builder: (_) => const CreateProjectScreen());
      case '/projects/detail':
        final projectId = settings.arguments as String?;
        if (projectId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Project ID required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: projectId),
        );
      case '/tasks':
        return MaterialPageRoute(builder: (_) => const TasksListScreen());
      case '/tasks/create':
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CreateTaskScreen(projectId: projectId),
        );
      case '/tasks/detail':
        final taskId = settings.arguments as String?;
        if (taskId == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(child: Text('Task ID required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => TaskDetailScreen(taskId: taskId),
        );
      case AppRoutes.welcome:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
