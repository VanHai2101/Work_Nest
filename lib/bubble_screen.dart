// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:work_nest/bubble_painter.dart';
import 'package:work_nest/bubble_physics.dart';

class BubbleScreen extends StatefulWidget {
  const BubbleScreen({super.key});

  @override
  State<BubbleScreen> createState() => _BubbleScreenState();
}

class _BubbleScreenState extends State<BubbleScreen>
    with SingleTickerProviderStateMixin {
  late BubblePhysicsWorld _world;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _time = 0.0;

  ui.FragmentShader? _shader;

  ui.Image? _bgSnapshot;
  final _repaintBoundaryKey = GlobalKey();

  bool _isDark = false;
  bool _isCapturing = false;
  int _frameCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _world = BubblePhysicsWorld(width: size.width, height: size.height);

    _world.bubbles.clear();
    _world.bubbles.add(Bubble(
      position: Offset(size.width / 2, size.height / 2),
      radius: 120,
    ));
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'assets/graphics/core/bubble.frag',
      );
      if (mounted) {
        setState(() => _shader = program.fragmentShader());
      }
    } catch (e) {
      debugPrint('Shader load error: $e');
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _time += dt;

    _world.step(dt);
    
    // Only capture background every 3 frames and if not already capturing
    // to prevent GPU resource exhaustion.
    _frameCounter++;
    if (_frameCounter % 3 == 0 && !_isCapturing) {
      _captureBackground();
    }

    if (mounted) setState(() {});
  }

  Future<void> _captureBackground() async {
    if (_isCapturing) return;
    _isCapturing = true;
    
    final boundary =
        _repaintBoundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
            
    if (boundary == null) {
      _isCapturing = false;
      return;
    }
    
    try {
      final img = await boundary.toImage(pixelRatio: 1.0);
      if (mounted) {
        _bgSnapshot?.dispose();
        _bgSnapshot = img;
      } else {
        img.dispose();
      }
    } catch (e) {
      debugPrint('Capture background error: $e');
    } finally {
      _isCapturing = false;
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_world.bubbles.isNotEmpty) {
      final hero = _world.bubbles.first;
      if (!hero.isPopped) {
        final dist = (hero.position - details.localPosition).distance;
        if (dist <= hero.radius) {
          HapticFeedback.mediumImpact();
          _world.spawnBurst(hero.position);
          hero.isPopped = true;

          // Respawn single bubble after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() {
              final size = MediaQuery.of(context).size;
              _world.bubbles[0] = Bubble(
                position: Offset(size.width / 2, size.height + 100),
                radius: 120,
              );
            });
          });
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (_world.bubbles.isNotEmpty) {
      final hero = _world.bubbles.first;
      if (!hero.isPopped) {
        final dist = (hero.position - details.localPosition).distance;
        if (dist <= hero.radius) {
          _world.isDragging = true;
          _world.activeBubble = hero;
          _world.dragTarget = details.localPosition;
        }
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_world.isDragging) {
      _world.dragTarget = details.localPosition;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _world.isDragging = false;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bgSnapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTapDown: _onTapDown,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            RepaintBoundary(
              key: _repaintBoundaryKey,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: _isDark
                            ? [const Color(0xFF1A1C1E), const Color(0xFF0D0E10)]
                            : [
                                const Color(0xFFF8F9FB),
                                const Color(0xFFE2E5E9),
                              ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SL PIPELINE',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              height: 0.9,
                              color: _isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Real-time thin-film interference\ndriven by kinematic springs.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: _isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            CustomPaint(
              painter: BubblePainter(
                world: _world,
                time: _time,
                shader: _shader,
                snapshot: _bgSnapshot,
              ),
              child: const SizedBox.expand(),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _GrainPainter(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: 52,
              right: 20,
              child: _ThemeToggle(
                isDark: _isDark,
                onToggle: () => setState(() => _isDark = !_isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.015);
    for (int i = 0; i < 2000; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false;
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onToggle});
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.07),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              key: ValueKey(isDark),
              size: 22,
              color: isDark ? Colors.amber : Colors.blueGrey,
            ),
          ),
        ),
      ),
    );
  }
}
