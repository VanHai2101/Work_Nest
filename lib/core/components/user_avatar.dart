import 'package:flutter/material.dart';
import '../theme/index.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.showBorder = false,
    this.borderColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.accent, width: 2)
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.accent.withOpacity(0.1),
        backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
            ? NetworkImage(imageUrl!)
            : null,
        child: (imageUrl == null || imageUrl!.isEmpty)
            ? Text(
                _getInitial(name),
                style: TextStyle(
                  color: AppColors.accentDark,
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }

  String _getInitial(String? name) {
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }
}
