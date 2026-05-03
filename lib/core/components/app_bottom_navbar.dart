import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/index.dart';
import '../constants/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/presentation/providers/chat_providers.dart';

class AppBottomNavbar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onAction;

  const AppBottomNavbar({
    required this.currentIndex,
    required this.onTap,
    this.onAction,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider);

    final items = [
      (Icons.dashboard_rounded, 'Dashboard'),
      (Icons.chat_bubble_rounded, 'Chats'),
      (Icons.calendar_today_rounded, 'Schedule'),
      (Icons.folder_rounded, 'Projects'),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.darkBorder.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(items.length, (i) {
                        final sel = currentIndex == i;
                        final (ico, label) = items[i];
                        final hasBadge = i == 1;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    if (sel)
                                      Positioned.fill(
                                        child: Center(
                                          child: Container(
                                            width: 40,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: AppColors.darkAccent
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Icon(
                                      ico,
                                      size: 22,
                                      color: sel
                                          ? AppColors.darkAccent
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                    if (hasBadge && unreadCount > 0)
                                      Positioned(
                                        right: -4,
                                        top: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.darkSurface,
                                              width: 1.5,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: sel
                                        ? AppColors.darkAccent
                                        : Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
