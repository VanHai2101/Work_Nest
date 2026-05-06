import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'island_models.dart';
import 'island_provider.dart';

class DynamicIslandWidget extends ConsumerStatefulWidget {
  const DynamicIslandWidget({super.key});

  @override
  ConsumerState<DynamicIslandWidget> createState() =>
      _DynamicIslandWidgetState();
}

class _DynamicIslandWidgetState extends ConsumerState<DynamicIslandWidget>
    with TickerProviderStateMixin {
  IslandData _islandData = const IslandData(state: IslandState.none);
  IslandState _nextState = IslandState.none;

  late AnimationController _shapeController;
  late AnimationController _contentController;

  late Animation<double> _widthAnim;
  late Animation<double> _heightAnim;
  late Animation<double> _radiusAnim;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();

    _shapeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buildAnimations(IslandState.none, IslandState.none);

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeInOut),
    );
  }

  void _buildAnimations(IslandState from, IslandState to) {
    final fromSize = islandSizes[from]!;
    final toSize = islandSizes[to]!;

    final curve = CurvedAnimation(
      parent: _shapeController,
      curve: Curves.elasticOut,
    );

    _widthAnim = Tween<double>(
      begin: fromSize.width,
      end: toSize.width,
    ).animate(curve);

    _heightAnim = Tween<double>(
      begin: fromSize.height,
      end: toSize.height,
    ).animate(curve);

    _radiusAnim = Tween<double>(
      begin: fromSize.radius,
      end: toSize.radius,
    ).animate(curve);
  }

  Future<void> _handleStateChange(IslandData newData) async {
    if (newData.state == _islandData.state &&
        newData.context == _islandData.context)
      return;

    // Phase 1: Fade out old content
    if (_islandData.state != IslandState.none) {
      await _contentController.reverse();
    }

    // Phase 2: Animate shape
    final fromState = _islandData.state;
    setState(() {
      _nextState = newData.state;
    });

    _buildAnimations(fromState, newData.state);
    _shapeController.reset();
    await _shapeController.forward();

    // Phase 3: Update state and fade in new content
    setState(() => _islandData = newData);
    _contentController.reset();
    if (_islandData.state != IslandState.none) {
      await _contentController.forward();
    }
  }

  @override
  void dispose() {
    _shapeController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to external state changes
    ref.listen(islandProvider, (previous, next) {
      _handleStateChange(next);
    });

    return AnimatedBuilder(
      animation: _shapeController,
      builder: (context, child) {
        if (_widthAnim.value <= 0.1) return const SizedBox.shrink();

        return GestureDetector(
          onLongPress: () => ref.read(islandProvider.notifier).collapse(),
          onTap: () {
            // Expansion logic could go here
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_radiusAnim.value),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: _widthAnim.value,
                height: _heightAnim.value,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(_radiusAnim.value),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: FadeTransition(
                  opacity: _contentFade,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final state = _islandData.state == IslandState.none
        ? _nextState
        : _islandData.state;
    final context = _islandData.context;

    switch (state) {
      case IslandState.musicPlayer:
        return const _MusicPlayerContent();
      case IslandState.phoneCall:
        return _PhoneCallContent(context: context);
      case IslandState.notification:
        return _NotificationContent(context: context);
      case IslandState.activeTask:
        return _TaskContent(context: context);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _MusicPlayerContent extends StatelessWidget {
  const _MusicPlayerContent();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFF9B59B6)],
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Blinding Lights',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'The Weeknd',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.skip_previous_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.skip_next_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.42,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1:47',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10),
              ),
              Text(
                '3:23',
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final IslandContext? context;
  const _TaskContent({this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (this.context?.color ?? Colors.green).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              this.context?.icon ?? Icons.play_arrow_rounded,
              color: this.context?.color ?? Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  this.context?.title ?? 'Active Task',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Working on...',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const _TimerWidget(),
        ],
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  const _TimerWidget();

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  int _seconds = 0;
  late final javaScriptTimer;

  @override
  void initState() {
    super.initState();
    // Simple mock timer
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return Text(
      '$minutes:$seconds',
      style: const TextStyle(
        color: Colors.green,
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

class _PhoneCallContent extends ConsumerWidget {
  final IslandContext? context;
  const _PhoneCallContent({this.context});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  this.context?.title ?? 'Unknown Caller',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF30D158), size: 8),
                    const SizedBox(width: 4),
                    Text(
                      this.context?.subtitle ?? '00:00',
                      style: const TextStyle(
                        color: Color(0xFF30D158),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _ActionButton(
            icon: Icons.call_end_rounded,
            color: Colors.red,
            onTap: () => ref.read(islandProvider.notifier).collapse(),
          ),
        ],
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  final IslandContext? context;
  const _NotificationContent({this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: this.context?.color ?? const Color(0xFF0A84FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              this.context?.icon ?? Icons.message_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  this.context?.title ?? 'Notification',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  this.context?.subtitle ?? '',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
