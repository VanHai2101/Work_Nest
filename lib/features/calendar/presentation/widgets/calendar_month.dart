import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/core/extensions/index.dart';
import '../providers/calendar_provider.dart';
import 'calendar_day_circle.dart';
import 'calendar_weekday_header.dart';

class CalendarMonthGrid extends ConsumerWidget {
  const CalendarMonthGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final today = DateTime.now();
    final focusedMonth = state.focusedMonth;
    final selectedDay = state.selectedDay;

    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startWeekday = firstDayOfMonth.weekday; // Mon=1, Sun=7
    final gridStart = firstDayOfMonth.subtract(
      Duration(days: startWeekday - 1),
    );

    const totalCells = 42;
    const totalRows = 6;

    final days = List.generate(
      totalCells,
      (i) => gridStart.add(Duration(days: i)),
    );

    return Column(
      children: [
        const CalendarWeekdayHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              final cellHeight = constraints.maxHeight / totalRows;

              return Stack(
                children: [
                  ...List.generate(totalRows - 1, (row) {
                    return Positioned(
                      top: (row + 1) * cellHeight,
                      left: 0,
                      right: 0,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    );
                  }),

                  ...List.generate(6, (col) {
                    return Positioned(
                      left: (col + 1) * cellWidth,
                      top: 0,
                      bottom: 0,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border.withOpacity(0.5),
                      ),
                    );
                  }),

                  // Các ô ngày
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: cellWidth / cellHeight,
                    ),
                    itemCount: totalCells,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isCurrentMonth = day.month == focusedMonth.month;
                      return CalendarDayCircle(
                        day: day.day,
                        isToday: day.isToday,
                        isSelected: selectedDay?.isSameDay(day) ?? false,
                        isSunday: day.isSunday,
                        isCurrentMonth: isCurrentMonth,
                        size: 28,
                        onTap: () =>
                            ref.read(calendarProvider.notifier).selectDay(day),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
