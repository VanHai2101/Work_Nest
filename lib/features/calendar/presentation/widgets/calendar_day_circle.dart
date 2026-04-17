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
      textColor = Colors.white;
    } else if (!isCurrentMonth) {
      textColor = AppColors.textTertiary.withOpacity(0.3);
    } else if (isSunday) {
      textColor = AppColors.error.withOpacity(0.8);
    } else {
      textColor = AppColors.textPrimary;
    }

    Color bgColor = Colors.transparent;
    if (isToday || isSelected) {
      bgColor = Colors.blue.shade600;
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: (isToday || isSelected)
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
              fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
