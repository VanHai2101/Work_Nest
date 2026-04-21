import 'package:flutter/material.dart';
import '../theme/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/index.dart';

class AppAvatar extends ConsumerWidget {
  final String id;
  final String? userId; // For real-time presence
  final String? photoURL;
  final double size;
  final bool isGroup;
  final bool showOnline;

  const AppAvatar({
    required this.id,
    this.userId,
    this.photoURL,
    this.size = 48,
    this.isGroup = false,
    this.showOnline = false,
    super.key,
  });

  Color _avatarColor(String id) {
    if (id == '?') return AppColors.darkTextHint;
    return AppColors.darkAvatarPalette[id.codeUnitAt(0) %
        AppColors.darkAvatarPalette.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarColor = _avatarColor(id);
    final initial = id.isNotEmpty ? id[0].toUpperCase() : '?';

    // Watch real status if userId is provided
    final bool isActuallyOnline = (showOnline && userId != null)
        ? (ref.watch(userOnlineStatusProvider(userId!)).value ?? false)
        : showOnline;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: avatarColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(size * 0.31),
            border: Border.all(color: avatarColor.withOpacity(0.3)),
          ),
          child: photoURL != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(size * 0.29),
                  child: Image.network(photoURL!, fit: BoxFit.cover),
                )
              : Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: avatarColor,
                      fontSize: size * 0.375,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        if (isActuallyOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.23,
              height: size * 0.23,
              decoration: BoxDecoration(
                color: AppColors.darkSuccess,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
