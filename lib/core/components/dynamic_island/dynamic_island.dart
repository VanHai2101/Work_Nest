import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'island_models.dart';
import 'island_provider.dart';

class DynamicIslandWidget extends ConsumerStatefulWidget {
  const DynamicIslandWidget({super.key});

  @override
  ConsumerState<DynamicIslandWidget> createState() => _DynamicIslandWidgetState();
}

class _DynamicIslandWidgetState extends ConsumerState<DynamicIslandWidget>
    with TickerProviderStateMixin {
  
  IslandState _state = IslandState.collapsed;
  IslandState _nextState = IslandState.collapsed;

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
      duration: const Duration(milliseconds: 420),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _buildAnimations(IslandState.collapsed, IslandState.collapsed);

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
  }

  void _buildAnimations(IslandState from, IslandState to) {
    final fromSize = islandSizes[from]!;
    final toSize = islandSizes[to]!;

    final curve = CurvedAnimation(
      parent: _shapeController,
      curve: Curves.easeOutBack,
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

  Future<void> _handleStateChange(IslandState newState) async {
    if (newState == _state) return;

    // Phase 1: Fade out old content
    if (_state != IslandState.collapsed) {
      await _contentController.reverse();
    }

    // Phase 2: Animate shape
    final fromState = _state;
    setState(() {
      _nextState = newState;
    });

    _buildAnimations(fromState, newState);
    _shapeController.reset();
    await _shapeController.forward();

    // Phase 3: Update state and fade in new content
    setState(() => _state = newState);
    _contentController.reset();
    if (_state != IslandState.collapsed) {
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
      if (next != _state) {
        _handleStateChange(next);
      }
    });

    return AnimatedBuilder(
      animation: _shapeController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => ref.read(islandProvider.notifier).collapse(),
          child: Container(
            width: _widthAnim.value,
            height: _heightAnim.value,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(_radiusAnim.value),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 20,
                  offset: Offset(0, 6),
                )
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: FadeTransition(
              opacity: _contentFade,
              child: _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_state == IslandState.collapsed ? _nextState : _state) {
      case IslandState.musicPlayer:
        return const _MusicPlayerContent();
      case IslandState.phoneCall:
        return const _PhoneCallContent();
      case IslandState.notification:
        return const _NotificationContent();
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
                child: const Icon(Icons.music_note_rounded,
                    color: Colors.white, size: 28),
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
              const Icon(Icons.skip_previous_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C2C2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.skip_next_rounded,
                  color: Colors.white, size: 22),
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
              Text('1:47',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10)),
              Text('3:23',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhoneCallContent extends StatelessWidget {
  const _PhoneCallContent();
  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nguyễn Văn A',
                  style: TextStyle(
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
                    const Text(
                      '00:42',
                      style: TextStyle(
                          color: Color(0xFF30D158), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_end_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3C),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _NotificationContent extends StatelessWidget {
  const _NotificationContent();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.message_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tin nhắn mới • Zalo',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Bạn có 3 tin nhắn chưa đọc',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFF3B30),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('3',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
