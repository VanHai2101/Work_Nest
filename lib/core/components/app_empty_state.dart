import 'package:flutter/material.dart';
import '../theme/index.dart';
import '../constants/index.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Icon(icon, size: 32, color: AppColors.darkAccent),
          ),
          AppLayout.gapMedium,
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppLayout.gapSmall,
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
