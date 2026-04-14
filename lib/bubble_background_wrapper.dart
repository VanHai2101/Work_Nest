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

class BubbleBackgroundWrapper extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;

  const BubbleBackgroundWrapper({
    super.key,
    required this.child,
    this.gradientColors = const [Color(0xFF8B0021), Color(0xFF2C000B)],
  });

  @override
  State<BubbleBackgroundWrapper> createState() => _BubbleBackgroundWrapperState();
}

class _BubbleBackgroundWrapperState extends State<BubbleBackgroundWrapper>
    with SingleTickerProviderStateMixin {
  late BubblePhysicsWorld _world;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _time = 0.0;
  final math.Random _random = math.Random();

  ui.FragmentShader? _shader;
  ui.Image? _bgSnapshot;
  final _repaintBoundaryKey = GlobalKey();

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

    // Initialize with 3 small bubbles at varied positions
    _spawnInitialBubbles(size);
  }

  void _spawnInitialBubbles(Size size) {
    _world.bubbles.clear();
    for (int i = 0; i < 3; i++) {
        _world.bubbles.add(_createRandomBubble(size));
    }
  }

  Bubble _createRandomBubble(Size size) {
    final double radius = 40.0 + _random.nextDouble() * 30.0;
    return Bubble(
      position: Offset(
        radius + _random.nextDouble() * (size.width - radius * 2),
        radius + _random.nextDouble() * (size.height - radius * 2),
      ),
      radius: radius,
    );
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
    for (int i = 0; i < _world.bubbles.length; i++) {
        final b = _world.bubbles[i];
        if (!b.isPopped) {
            final dist = (b.position - details.localPosition).distance;
            if (dist <= b.radius) {
                HapticFeedback.mediumImpact();
                _world.spawnBurst(b.position);
                b.isPopped = true;

                // Respawn this specific bubble after delay
                Future.delayed(const Duration(seconds: 2), () {
                    if (!mounted) return;
                    setState(() {
                        final size = MediaQuery.of(context).size;
                        // Replace the popped bubble with a new one
                        _world.bubbles[i] = _createRandomBubble(size);
                    });
                });
                break; // Only pop one bubble at a time
            }
        }
    }
  }

  void _onPanStart(DragStartDetails details) {
    for (var b in _world.bubbles) {
        if (!b.isPopped) {
            final dist = (b.position - details.localPosition).distance;
            if (dist <= b.radius) {
                _world.isDragging = true;
                _world.activeBubble = b;
                _world.dragTarget = details.localPosition;
                break;
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
    _world.activeBubble = null;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _bgSnapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onTapDown,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.gradientColors,
                ),
              ),
              child: const SizedBox.expand(),
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

          widget.child,
        ],
      ),
    );
  }
}
