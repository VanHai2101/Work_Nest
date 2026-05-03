import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/index.dart' show AppColors;
import '../../../../core/constants/index.dart';
import '../providers/auth_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../app/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppDuration.animationLong,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final localStorage = ref.read(localStorageServiceProvider);
    final onboardingDone = await localStorage.isOnboardingCompleted();
    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          if (onboardingDone) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
          }
        }
      },
      loading: () {
        // Just wait
      },
      error: (_, _) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Container(
                  width: AppSize.iconXLarge * 1.5,
                  height: AppSize.iconXLarge * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    size: AppSize.iconXLarge,
                    color: AppColors.accentDark,
                  ),
                ),
                AppLayout.gapLarge,
                Text(
                  'Hải Tới Đây!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                AppLayout.gapSmall,
                Text(
                  'Collaborate, Connect, Achieve',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                AppLayout.gapXLarge,
                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
