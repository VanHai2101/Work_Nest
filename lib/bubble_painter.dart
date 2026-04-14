// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'bubble_physics.dart';
import 'dart:math' as math;

class BubblePainter extends CustomPainter {
  BubblePainter({
    required this.world,
    required this.time,
    this.shader,
    this.snapshot,
  });

  final BubblePhysicsWorld world;
  final double time;
  final ui.FragmentShader? shader;
  final ui.Image? snapshot;

  @override
  void paint(Canvas canvas, Size size) {
    _drawParticles(canvas);

    if (shader == null || snapshot == null) {
      for (var b in world.bubbles) {
        if (!b.isPopped) {
          canvas.drawCircle(
            b.position,
            b.radius,
            Paint()..color = Colors.blue.withOpacity(0.2),
          );
        }
      }
      return;
    }

    final double pulse = math.sin(time * 1.5) * 3.0;

    // Set uniforms for up to 3 bubbles
    for (int i = 0; i < 3; i++) {
        final int offset = i * 6;
        if (i < world.bubbles.length) {
            final b = world.bubbles[i];
            shader!..setFloat(offset + 0, b.position.dx)
                  ..setFloat(offset + 1, b.position.dy)
                  ..setFloat(offset + 2, b.radius + pulse)
                  ..setFloat(offset + 3, b.deformation.dx)
                  ..setFloat(offset + 4, b.deformation.dy)
                  ..setFloat(offset + 5, b.isPopped ? 1.0 : b.popProgress); // uPop
        } else {
            // Fill with dummy data (popped = 1.0 ensures it doesn't draw)
            shader!..setFloat(offset + 0, 0.0)
                  ..setFloat(offset + 1, 0.0)
                  ..setFloat(offset + 2, 0.0)
                  ..setFloat(offset + 3, 0.0)
                  ..setFloat(offset + 4, 0.0)
                  ..setFloat(offset + 5, 1.0);
        }
    }

    // Previous indices were 0-17. 
    // New indices (after 18 floats for bubbles):
    // uTime: 18, uResolution: 19,20, uTexture: Sampler 0
    shader!..setFloat(18, time)
          ..setFloat(19, size.width)
          ..setFloat(20, size.height)
          ..setImageSampler(0, snapshot!);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);

    // Draw highlights for all bubbles
    for (var b in world.bubbles) {
      if (!b.isPopped) {
        _drawHighlight(canvas, b, pulse);
      }
    }
  }

  void _drawParticles(Canvas canvas) {
    for (var p in world.particles) {
      final paint = Paint()
        ..color = p.color.withOpacity(p.life.clamp(0.0, 1.0));
      canvas.drawCircle(p.position, 2.0 + p.life * 3.0, paint);
    }
  }

  void _drawHighlight(Canvas canvas, Bubble b, double pulse) {
    final r = b.radius + pulse;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.45), Colors.transparent],
        center: const Alignment(-0.35, -0.35),
      ).createShader(Rect.fromCircle(center: b.position, radius: r));
    canvas.drawCircle(b.position, r, paint);
  }

  @override
  bool shouldRepaint(BubblePainter old) => true;
}
