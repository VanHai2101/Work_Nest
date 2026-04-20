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
    final focusedMonth = state.focusedMonth;
    final selectedDay = state.selectedDay;

    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final startWeekday = firstDayOfMonth.weekday;
    final gridStart = firstDayOfMonth.subtract(
      Duration(days: startWeekday - 1),
    );

    const totalCells = 42;
    final days = List.generate(
      totalCells,
      (i) => gridStart.add(Duration(days: i)),
    );

    final eventsAsync = ref.watch(
      calendarEventsProvider((start: days.first, end: days.last)),
    );

    return Column(
      children: [
        const CalendarWeekdayHeader(),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              border: Border.all(
                color: Colors.black.withOpacity(0.05),
                width: 0.5,
              ),
            ),
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
              data: (events) => GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final day = days[index];
                  final isCurrentMonth = day.month == focusedMonth.month;
                  final isSelected = selectedDay?.isSameDay(day) ?? false;

                  final dayEvents = events
                      .where((e) => e.startTime.isSameDay(day))
                      .toList();

                  return _MonthDayCell(
                    day: day,
                    isCurrentMonth: isCurrentMonth,
                    isSelected: isSelected,
                    eventCount: dayEvents.length,
                    onTap: () =>
                        ref.read(calendarProvider.notifier).selectDay(day),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  final DateTime day;
  final bool isCurrentMonth;
  final bool isSelected;
  final int eventCount;
  final VoidCallback onTap;

  const _MonthDayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.eventCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day.isToday;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.03), width: 0.5),
          color: isSelected
              ? Colors.blue.withOpacity(0.02)
              : Colors.transparent,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CalendarDayCircle(
                  day: day.day,
                  isToday: isToday,
                  isSelected: isSelected,
                  isCurrentMonth: isCurrentMonth,
                  isSunday: day.isSunday,
                  size: 24,
                ),
              ],
            ),
            const Spacer(),
            if (isCurrentMonth && eventCount > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Text(
                  '$eventCount công việc',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
