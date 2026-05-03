import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';

// ─── Data Model ────────────────────────────────────────────────────────────────

class OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;
  final Color cardColor;
  // ignore: library_private_types_in_public_api
  final List<_FloatingShape> shapes;

  const OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
    required this.cardColor,
    required this.shapes,
  });
}

class _FloatingShape {
  final double top;
  final double left;
  final double size;
  final Color color;
  final ShapeType type;
  final double opacity;

  const _FloatingShape({
    required this.top,
    required this.left,
    required this.size,
    required this.color,
    required this.type,
    this.opacity = 0.18,
  });
}

enum ShapeType { circle, square, triangle, blob }

final List<OnboardingData> onboardingPages = [
  OnboardingData(
    emoji: '🗂️',
    title: 'Quản lý công việc\nsiêu dễ dàng',
    subtitle:
        'Tổ chức task, deadline và dự án của bạn\ntrong một nơi duy nhất. Không bao giờ\nbỏ lỡ việc quan trọng nữa!',
    bgColor: const Color(0xFFFFF0E6),
    accentColor: const Color(0xFFFF6B35),
    cardColor: const Color(0xFFFFE0CC),
    shapes: [
      _FloatingShape(
        top: 0.05,
        left: 0.78,
        size: 90,
        color: Color(0xFFFF6B35),
        type: ShapeType.circle,
      ),
      _FloatingShape(
        top: 0.15,
        left: -0.05,
        size: 60,
        color: Color(0xFFFFB347),
        type: ShapeType.square,
      ),
      _FloatingShape(
        top: 0.72,
        left: 0.82,
        size: 50,
        color: Color(0xFFFF6B35),
        type: ShapeType.triangle,
      ),
      _FloatingShape(
        top: 0.80,
        left: 0.02,
        size: 70,
        color: Color(0xFFFFD700),
        type: ShapeType.circle,
        opacity: 0.15,
      ),
      _FloatingShape(
        top: 0.55,
        left: 0.88,
        size: 30,
        color: Color(0xFFFF6B35),
        type: ShapeType.square,
        opacity: 0.25,
      ),
    ],
  ),
  OnboardingData(
    emoji: '👥',
    title: 'Cộng tác nhóm\nthật mượt mà',
    subtitle:
        'Chat, giao việc và theo dõi tiến độ\ncùng đồng nghiệp theo thời gian thực.\nTeamwork chưa bao giờ vui thế!',
    bgColor: const Color(0xFFE8F4FF),
    accentColor: const Color(0xFF3B82F6),
    cardColor: const Color(0xFFCCE4FF),
    shapes: [
      _FloatingShape(
        top: 0.04,
        left: 0.72,
        size: 100,
        color: Color(0xFF3B82F6),
        type: ShapeType.blob,
      ),
      _FloatingShape(
        top: 0.18,
        left: -0.08,
        size: 55,
        color: Color(0xFF60A5FA),
        type: ShapeType.circle,
      ),
      _FloatingShape(
        top: 0.76,
        left: 0.80,
        size: 45,
        color: Color(0xFF93C5FD),
        type: ShapeType.square,
      ),
      _FloatingShape(
        top: 0.82,
        left: 0.05,
        size: 65,
        color: Color(0xFF3B82F6),
        type: ShapeType.triangle,
        opacity: 0.12,
      ),
      _FloatingShape(
        top: 0.50,
        left: -0.02,
        size: 35,
        color: Color(0xFF60A5FA),
        type: ShapeType.circle,
        opacity: 0.2,
      ),
    ],
  ),
  OnboardingData(
    emoji: '📊',
    title: 'Báo cáo thông minh\nmọi lúc mọi nơi',
    subtitle:
        'Dashboard trực quan, biểu đồ đẹp mắt\ngiúp bạn nắm bắt hiệu suất ngay\ntrên đầu ngón tay.',
    bgColor: const Color(0xFFF0FFF4),
    accentColor: const Color(0xFF10B981),
    cardColor: const Color(0xFFC6F6D5),
    shapes: [
      _FloatingShape(
        top: 0.06,
        left: 0.75,
        size: 85,
        color: Color(0xFF10B981),
        type: ShapeType.circle,
      ),
      _FloatingShape(
        top: 0.14,
        left: -0.06,
        size: 65,
        color: Color(0xFF34D399),
        type: ShapeType.blob,
      ),
      _FloatingShape(
        top: 0.74,
        left: 0.84,
        size: 55,
        color: Color(0xFF6EE7B7),
        type: ShapeType.circle,
      ),
      _FloatingShape(
        top: 0.78,
        left: 0.00,
        size: 70,
        color: Color(0xFF10B981),
        type: ShapeType.square,
        opacity: 0.13,
      ),
      _FloatingShape(
        top: 0.48,
        left: 0.90,
        size: 32,
        color: Color(0xFF34D399),
        type: ShapeType.triangle,
        opacity: 0.22,
      ),
    ],
  ),
];

// ─── Main Onboarding Screen ─────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _contentController;
  late Animation<double> _floatAnim;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Mark onboarding as completed
      await ref.read(localStorageServiceProvider).setOnboardingCompleted();

      // Navigate to Login
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _contentController.reset();
    _contentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = onboardingPages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: data.bgColor,
        child: Stack(
          children: [
            // ── Floating shapes background ──
            ..._buildShapes(data, size),

            // ── PageView ──
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: onboardingPages.length,
              itemBuilder: (_, index) => _PageContent(
                data: onboardingPages[index],
                floatAnim: _floatAnim,
                contentFade: _contentFade,
                contentSlide: _contentSlide,
                isActive: index == _currentPage,
                size: size,
              ),
            ),

            // ── Bottom UI ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomBar(
                currentPage: _currentPage,
                total: onboardingPages.length,
                accentColor: data.accentColor,
                onNext: _nextPage,
                onSkip: () => _pageController.animateToPage(
                  onboardingPages.length - 1,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                ),
                isLast: _currentPage == onboardingPages.length - 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildShapes(OnboardingData data, Size size) {
    return data.shapes.map((s) {
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        top: s.top * size.height,
        left: s.left * size.width,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (_, _) {
            return Transform.translate(
              offset: Offset(0, _floatAnim.value * (s.top < 0.5 ? 1 : -0.7)),
              child: Opacity(
                opacity: s.opacity,
                child: _ShapeWidget(shape: s),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}


class _PageContent extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> floatAnim;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;
  final bool isActive;
  final Size size;

  const _PageContent({
    required this.data,
    required this.floatAnim,
    required this.contentFade,
    required this.contentSlide,
    required this.isActive,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ── Illustration Card ──
            Center(
              child: AnimatedBuilder(
                animation: floatAnim,
                builder: (_, _) => Transform.translate(
                  offset: Offset(0, isActive ? floatAnim.value : 0),
                  child: _IllustrationCard(data: data, size: size),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Text content ──
            FadeTransition(
              opacity: isActive ? contentFade : const AlwaysStoppedAnimation(1),
              child: SlideTransition(
                position: isActive
                    ? contentSlide
                    : const AlwaysStoppedAnimation(Offset.zero),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: data.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'WorkMate ✨',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: data.accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize: 15.5,
                        color: const Color(0xFF1A1A2E).withOpacity(0.55),
                        height: 1.65,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120), 
          ],
        ),
      ),
    );
  }
}


class _IllustrationCard extends StatelessWidget {
  final OnboardingData data;
  final Size size;

  const _IllustrationCard({required this.data, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.78,
      height: size.width * 0.68,
      decoration: BoxDecoration(
        color: data.cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 0,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size.width * 0.42,
            height: size.width * 0.42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.accentColor.withOpacity(0.1),
            ),
          ),
          Positioned(
            top: 22,
            right: 22,
            child: _MiniCard(color: data.accentColor, width: 70, height: 18),
          ),
          Positioned(
            top: 48,
            right: 22,
            child: _MiniCard(
              color: data.accentColor.withOpacity(0.5),
              width: 50,
              height: 14,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 24,
            child: _ProgressMini(color: data.accentColor),
          ),
          Text(data.emoji, style: const TextStyle(fontSize: 80)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final Color color;
  final double width;
  final double height;

  const _MiniCard({
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _ProgressMini extends StatelessWidget {
  final Color color;

  const _ProgressMini({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.72,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 55,
          height: 8,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.45,
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int total;
  final Color accentColor;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLast;

  const _BottomBar({
    required this.currentPage,
    required this.total,
    required this.accentColor,
    required this.onNext,
    required this.onSkip,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white.withOpacity(0.0)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots
          Row(
            children: List.generate(total, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 8),
                width: isActive ? 28 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive ? accentColor : accentColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),

          // Next / Get Started Button
          GestureDetector(
            onTap: onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              padding: EdgeInsets.symmetric(
                horizontal: isLast ? 24 : 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    isLast ? 'Bắt đầu ngay' : 'Tiếp tục',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Shape Widget ────────────────────────────────────────────────────

class _ShapeWidget extends StatelessWidget {
  final _FloatingShape shape;

  const _ShapeWidget({required this.shape});

  @override
  Widget build(BuildContext context) {
    switch (shape.type) {
      case ShapeType.circle:
        return Container(
          width: shape.size,
          height: shape.size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: shape.color),
        );
      case ShapeType.square:
        return Transform.rotate(
          angle: math.pi / 5,
          child: Container(
            width: shape.size,
            height: shape.size,
            decoration: BoxDecoration(
              color: shape.color,
              borderRadius: BorderRadius.circular(shape.size * 0.2),
            ),
          ),
        );
      case ShapeType.triangle:
        return CustomPaint(
          size: Size(shape.size, shape.size),
          painter: _TrianglePainter(color: shape.color),
        );
      case ShapeType.blob:
        return Container(
          width: shape.size,
          height: shape.size * 0.85,
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(shape.size * 0.6),
              topRight: Radius.circular(shape.size * 0.3),
              bottomLeft: Radius.circular(shape.size * 0.4),
              bottomRight: Radius.circular(shape.size * 0.7),
            ),
          ),
        );
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
