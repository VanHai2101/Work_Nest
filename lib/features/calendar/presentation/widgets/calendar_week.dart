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
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Column(
                  children: [
                    // Nhãn thứ (T2, T3...)
                    Text(
                      day.weekdayNameVi,
                      style: TextStyle(
                        color: day.isSunday
                            ? AppColors.error.withOpacity(0.8)
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Circle ngày
                    CalendarDayCircle(
                      day: day.day,
                      isToday: day.isToday,
                      isSelected: state.selectedDay?.isSameDay(day) ?? false,
                      isSunday: day.isSunday,
                      size: 34,
                      onTap: () => ref.read(calendarProvider.notifier).selectDay(day),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // ── Khu vực sự kiện theo giờ ──
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(24, (hour) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  height: 56,
                  child: Row(
                    children: [
                      // Nhãn giờ (bên trái)
                      SizedBox(
                        width: 48,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            hour == 0
                                ? ''
                                : '${hour.toString().padLeft(2, '0')}:00',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      // Đường kẻ dọc phân cách giờ và nội dung
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: AppColors.border.withOpacity(0.4),
                      ),
                      // Khu vực sự kiện (7 cột)
                      Expanded(
                        child: Row(
                          children: List.generate(7, (dayIndex) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: dayIndex < 6
                                        ? BorderSide(
                                            color: AppColors.border.withOpacity(
                                              0.3,
                                            ),
                                            width: 1,
                                          )
                                        : BorderSide.none,
                                  ),
                                ),
                                // TODO: Hiển thị sự kiện ở đây
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
      ],
    );
  }
}
