import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/core/extensions/index.dart';
import '../../domain/entities/index.dart';
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
    final weekStart = weekDays.first;

    final weekEnd = weekDays.last.add(const Duration(days: 1));
    final eventsAsync = ref.watch(
      calendarEventsProvider((start: weekStart, end: weekEnd)),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            border: Border(
              bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const SizedBox(width: 60),
              ...weekDays.map((day) {
                final isSelected = state.selectedDay?.isSameDay(day) ?? false;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        day.weekdayShortVi.toUpperCase(),
                        style: TextStyle(
                          color: day.isSunday
                              ? Colors.red.withOpacity(0.8)
                              : Colors.black38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CalendarDayCircle(
                        day: day.day,
                        isToday: day.isToday,
                        isSelected: isSelected,
                        size: 36,
                        onTap: () =>
                            ref.read(calendarProvider.notifier).selectDay(day),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // ── Khu vực sự kiện theo giờ ──
        Expanded(
          child: eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Lỗi: $err')),
            data: (events) => SingleChildScrollView(
              child: Container(
                color: AppColors.primaryBackground,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột nhãn giờ
                    Column(
                      children: List.generate(24, (hour) {
                        return Container(
                          width: 60,
                          height: 60,
                          padding: const EdgeInsets.only(top: 8, right: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black.withOpacity(0.03),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.black26,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }),
                    ),

                    // 7 Cột ngày
                    ...weekDays.map((day) {
                      final dayEvents = events
                          .where((e) => e.startTime.isSameDay(day))
                          .toList();

                      return Expanded(
                        child: Stack(
                          children: [
                            // Lưới nền
                            Column(
                              children: List.generate(24, (hour) {
                                return Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.03),
                                        width: 0.5,
                                      ),
                                      left: BorderSide(
                                        color: Colors.black.withOpacity(0.03),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            // Các sự kiện
                            ...dayEvents.map((e) => _buildEventBar(e)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventBar(CalendarEvent event) {
    final start = event.startTime;
    final end = event.endTime ?? start.add(const Duration(hours: 1));

    final top = (start.hour + (start.minute / 60)) * 60.0;
    final durationInMinutes = end.difference(start).inMinutes;
    final height = (durationInMinutes / 60) * 60.0;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height.clamp(4.0, 1000.0),
      child: Container(
        decoration: BoxDecoration(
          color: event.color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

}
