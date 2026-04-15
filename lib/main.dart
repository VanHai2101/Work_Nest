import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/features/home/presentation/widgets/auth_gate.dart';
import 'package:work_nest/features/calls/presentation/widgets/incoming_call_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Work Nest',
      theme: ThemeData.dark(useMaterial3: true),
      builder: (context, child) => IncomingCallOverlay(child: child!),
      home: const AuthGate(),
    );
  }
}
