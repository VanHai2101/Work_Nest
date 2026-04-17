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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isSundayCol = i == 6;
          return Expanded(
            child: Center(
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isSundayCol
                      ? Colors.red.withOpacity(0.7)
                      : Colors.black45,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
