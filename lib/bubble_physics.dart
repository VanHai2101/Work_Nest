import 'dart:ui';
import 'dart:math' as math;

class BubbleConfig {
  static const double maxRadius = 160.0;
  static const double minRadius = 40.0;
  static const double gravity = 200.0;
  static const double friction = 0.95;
  static const double bounce = 0.8;
  static const double stiffness = 2200.0;
  static const double damping = 50.0;
  static const double dragStiffness = 3000.0;
  static const double dragDamping = 80.0;
}

class Particle {
  Offset position;
  Offset velocity;
  double life = 1.0;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
  });

  void update(double dt) {
    velocity += const Offset(0, 400.0) * dt;
    position += velocity * dt;
    life -= dt * 1.5;
  }
}

class Bubble {
  Offset position;
  Offset prevPosition;
  Offset acceleration = Offset.zero;
  double radius;

  Offset deformation = Offset.zero;
  Offset _defVelocity = Offset.zero;

  bool isPopped = false;
  double popProgress = 0.0;

  Bubble({required this.position, required this.radius})
    : prevPosition = position;

  void applyForce(Offset force) => acceleration += force;

  void update(double dt) {
    if (isPopped) {
      popProgress = (popProgress + dt / 0.16).clamp(0.0, 1.0);
      return;
    }

    final vel = (position - prevPosition) * BubbleConfig.friction;
    prevPosition = position;
    position += vel + acceleration * (dt * dt);
    acceleration = Offset.zero;

    _updateWobble(dt, vel / dt);
  }

  void _updateWobble(double dt, Offset velocity) {
    final speed = velocity.distance;
    final moveDir = speed > 0.1 ? velocity / speed : Offset.zero;
    final target = moveDir * (speed * 0.0006).clamp(0.0, 0.45);
    final force =
        (target - deformation) * BubbleConfig.stiffness -
        _defVelocity * BubbleConfig.damping;
    _defVelocity += force * dt;
    deformation += _defVelocity * dt;
  }
}

class BubblePhysicsWorld {
  final double width;
  final double height;
  final List<Bubble> bubbles = [];
  final List<Particle> particles = [];

  bool isDragging = false;
  Bubble? activeBubble;
  Offset dragTarget = Offset.zero;

  BubblePhysicsWorld({required this.width, required this.height});

  void spawnBurst(Offset pos) {
    final random = math.Random();
    final colors = [
      const Color(0xFFFF9999),
      const Color(0xFF99FF99),
      const Color(0xFF9999FF),
      const Color(0xFFFFFF99),
    ];
    for (int i = 0; i < 20; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 100.0 + random.nextDouble() * 300.0;
      particles.add(
        Particle(
          position: pos,
          velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
          color: colors[random.nextInt(colors.length)].withOpacity(0.6),
        ),
      );
    }
  }

  void step(double dt) {
    if (dt <= 0) return;
    dt = dt.clamp(0.0, 0.016);

    if (isDragging && activeBubble != null) {
      final currentVel = (activeBubble!.position - activeBubble!.prevPosition) / dt;
      final dragForce =
          (dragTarget - activeBubble!.position) * BubbleConfig.dragStiffness -
          currentVel * BubbleConfig.dragDamping;
      activeBubble!.applyForce(dragForce);
    }

    for (var bubble in bubbles) {
      bubble.update(dt);
    }

    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update(dt);
      if (particles[i].life <= 0) particles.removeAt(i);
    }

    _handleBoundaries();
  }

  void _handleBoundaries() {
    for (var bubble in bubbles) {
      if (bubble.isPopped) continue;
      final r = bubble.radius;

      if (bubble.position.dx < r) {
        bubble.position = Offset(r, bubble.position.dy);
        bubble.prevPosition = Offset(
          bubble.position.dx +
              (bubble.position.dx - bubble.prevPosition.dx) * BubbleConfig.bounce,
          bubble.prevPosition.dy,
        );
      } else if (bubble.position.dx > width - r) {
        bubble.position = Offset(width - r, bubble.position.dy);
        bubble.prevPosition = Offset(
          bubble.position.dx +
              (bubble.position.dx - bubble.prevPosition.dx) * BubbleConfig.bounce,
          bubble.prevPosition.dy,
        );
      }

      if (bubble.position.dy < r) {
        bubble.position = Offset(bubble.position.dx, r);
        bubble.prevPosition = Offset(
          bubble.prevPosition.dx,
          bubble.position.dy +
              (bubble.position.dy - bubble.prevPosition.dy) * BubbleConfig.bounce,
        );
      } else if (bubble.position.dy > height - r) {
        bubble.position = Offset(bubble.position.dx, height - r);
        bubble.prevPosition = Offset(
          bubble.prevPosition.dx,
          bubble.position.dy +
              (bubble.position.dy - bubble.prevPosition.dy) * BubbleConfig.bounce,
        );
      }
    }
  }
}
