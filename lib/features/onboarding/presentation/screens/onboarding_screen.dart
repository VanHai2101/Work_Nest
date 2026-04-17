import 'package:flutter/material.dart';
import 'package:work_nest/core/theme/index.dart' show AppColors;
import '../../../../core/constants/index.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingStep> steps = [
    _OnboardingStep(
      title: 'Welcome to Work Nest',
      subtitle: 'Collaborate, Connect, Achieve',
      description: 'Manage projects and tasks efficiently with your team.',
      icon: Icons.workspace_premium,
      color: Colors.blue,
    ),
    _OnboardingStep(
      title: 'Create Projects',
      subtitle: 'Organize Your Work',
      description:
          'Create projects, set deadlines, and track progress in real-time.',
      icon: Icons.folder,
      color: Colors.green,
    ),
    _OnboardingStep(
      title: 'Assign Tasks',
      subtitle: 'Manage Your Team',
      description:
          'Assign tasks to team members and monitor completion status.',
      icon: Icons.task,
      color: Colors.orange,
    ),
    _OnboardingStep(
      title: 'Real-time Chat',
      subtitle: 'Collaborate Instantly',
      description: 'Chat with team members, share files, and stay connected.',
      icon: Icons.chat_bubble,
      color: Colors.purple,
    ),
    _OnboardingStep(
      title: 'Video Calls',
      subtitle: 'Face to Face',
      description: 'Make video calls with your team members.',
      icon: Icons.video_call,
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: steps.length,
            itemBuilder: (context, index) {
              final step = steps[index];
              return _OnboardingPage(step: step);
            },
          ),
          // Navigation dots
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: AppPadding.small),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Positioned(
            bottom: 30,
            left: AppPadding.medium,
            right: AppPadding.medium,
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: SizedBox(
                      height: AppSize.buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: AppDuration.animationMedium,
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                if (_currentPage > 0) AppLayout.horizontalGapSmall,
                Expanded(
                  child: SizedBox(
                    height: AppSize.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == steps.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: AppDuration.animationMedium,
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                      ),
                      child: Text(
                        _currentPage == steps.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingStep step;

  const _OnboardingPage({required this.step, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBackground,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 100, color: step.color),
          ),
          AppLayout.gapXLarge,
          Padding(
            padding: AppLayout.paddingMedium,
            child: Column(
              children: [
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppLayout.gapSmall,
                Text(
                  step.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: step.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppLayout.gapMedium,
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  _OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
