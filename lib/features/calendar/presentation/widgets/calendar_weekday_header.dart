import 'package:flutter/material.dart';
import 'package:work_nest/core/theme/index.dart';

class CalendarWeekdayHeader extends StatelessWidget {
  final List<String> labels;
  
  const CalendarWeekdayHeader({
    super.key, 
    this.labels = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSundayCol = i == 6;
          return Expanded(
            child: Center(
              child: Text(
                labels[i],
                style: AppTextStyles.caption.copyWith(
                  color: isSundayCol
                      ? AppColors.error.withOpacity(0.8)
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
