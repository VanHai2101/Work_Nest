import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/core/extensions/index.dart';
import '../providers/calendar_provider.dart';
import 'calendar_day_circle.dart';

class CalendarDayView extends ConsumerStatefulWidget {
  const CalendarDayView({super.key});

  @override
  ConsumerState<CalendarDayView> createState() => _CalendarDayViewState();
}

class _CalendarDayViewState extends ConsumerState<CalendarDayView> {
  final ScrollController _scrollController = ScrollController();
  static const double _hourHeight = 64.0;

  @override
  void initState() {
    super.initState();
    // Auto-scroll đến giờ hiện tại sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final offset = (now.hour - 1).clamp(0, 23) * _hourHeight;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);
    final today = DateTime.now();
    final selectedDay = state.selectedDay ?? today;
    final isToday = selectedDay.isSameDay(today);

    final dayLabel = selectedDay.weekdayFullVi.toUpperCase();

    return Column(
      children: [
        // ── Header ngày ──
        _buildDayHeader(selectedDay, dayLabel, isToday, today),

        // ── Lưới giờ ──
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              color: AppColors.primaryBackground,
              child: Stack(
                children: [
                  // Các hàng giờ
                  Column(
                    children: List.generate(24, (hour) => _buildHourRow(hour)),
                  ),

                  if (isToday) _buildCurrentTimeLine(today),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(
    DateTime day,
    String dayLabel,
    bool isToday,
    DateTime today,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CalendarDayCircle(day: day.day, isToday: isToday, isSelected: true, size: 44),
              const SizedBox(width: 16),
              Text(
                '${day.monthNameVi} ${day.year}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    return Container(
      height: _hourHeight,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhãn giờ
          Container(
            width: 60,
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Đường kẻ dọc phân cách (Optional, images show it very subtle or absent)
          Container(width: 0.5, color: Colors.black.withOpacity(0.05)),

          // Khu vực nội dung
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeLine(DateTime now) {
    final minuteOffset = now.hour * _hourHeight + (now.minute / 60) * _hourHeight;

    return Positioned(
      top: minuteOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 60,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: Colors.blueAccent.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
