import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/core/extensions/index.dart';
import '../providers/calendar_provider.dart';
import 'calendar_day_circle.dart';

class CalendarWeekView extends ConsumerWidget {
  const CalendarWeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final today = DateTime.now();
    final focusedDay = state.selectedDay ?? today;
    final weekDays = focusedDay.daysInWeek;

    return Column(
      children: [
        // ── Header: 7 ngày trong tuần ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 60), // Space for time labels
              ...weekDays.map((day) {
                final isSelected = state.selectedDay?.isSameDay(day) ?? false;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        day.weekdayNameVi.toUpperCase(),
                        style: TextStyle(
                          color: day.isSunday ? Colors.red.withOpacity(0.7) : Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CalendarDayCircle(
                        day: day.day,
                        isToday: day.isToday,
                        isSelected: isSelected,
                        size: 36,
                        onTap: () => ref.read(calendarProvider.notifier).selectDay(day),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        // ── Khu vực sự kiện theo giờ ──
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              color: AppColors.primaryBackground,
              child: Column(
                children: List.generate(24, (hour) {
                  return Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black.withOpacity(0.03),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Nhãn giờ
                        Container(
                          width: 60,
                          padding: const EdgeInsets.only(top: 8, right: 12),
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black26,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Các cột ngày (7 cột)
                        Expanded(
                          child: Row(
                            children: List.generate(7, (dayIndex) {
                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.black.withOpacity(0.03),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
