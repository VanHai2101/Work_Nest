import 'package:flutter/material.dart';
import 'package:work_nest/core/theme/index.dart';

class CalendarDayCircle extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool isSunday;
  final bool isCurrentMonth;
  final double size;
  final VoidCallback? onTap;

  const CalendarDayCircle({
    super.key,
    required this.day,
    this.isToday = false,
    this.isSelected = false,
    this.isSunday = false,
    this.isCurrentMonth = true,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (isToday || isSelected) {
      textColor = AppColors.primaryBackground;
    } else if (!isCurrentMonth) {
      textColor = AppColors.textTertiary.withOpacity(0.35);
    } else if (isSunday) {
      textColor = AppColors.error.withOpacity(0.85);
    } else {
      textColor = AppColors.textPrimary;
    }

    Color bgColor = Colors.transparent;
    if (isToday) {
      bgColor = AppColors.info;
    } else if (isSelected) {
      bgColor = AppColors.accent;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          boxShadow: isToday
              ? [
                  BoxShadow(
                    color: AppColors.info.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.45,
            fontWeight: isToday
                ? FontWeight.w800
                : isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
