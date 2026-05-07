import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:work_nest/core/theme/index.dart' show AppTheme;
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/features/auth/presentation/providers/index.dart';
import 'package:work_nest/features/calls/presentation/widgets/incoming_call_overlay.dart';
import 'package:work_nest/core/components/dynamic_island/dynamic_island_overlay.dart';
import 'package:work_nest/core/services/deep_link_service.dart';
import 'package:work_nest/app/index.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(presenceProvider);
    ref.watch(deepLinkServiceProvider);
    ref.watch(deviceInitializerProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,

      title: 'Work Nest',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
      builder: (context, child) => DynamicIslandOverlay(
        child: IncomingCallOverlay(child: child!),
      ),
    );
  }
}
