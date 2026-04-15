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
    final isToday =
        selectedDay.year == today.year &&
        selectedDay.month == today.month &&
        selectedDay.day == today.day;

    final dayLabel = selectedDay.weekdayFullVi;

    return Column(
      children: [
        // ── Header ngày ──
        _buildDayHeader(selectedDay, dayLabel, isToday, today),

        // ── Lưới giờ + current time indicator ──
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              // Chiều cao đủ cho 24 giờ
              height: 24 * _hourHeight,
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Circle ngày
          CalendarDayCircle(day: day.day, isToday: isToday, size: 40),

          const SizedBox(width: 12),

          // Tên thứ + tháng/năm
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Tháng ${day.month}, ${day.year}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),

          const Spacer(),

          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'HÔM NAY',
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    return SizedBox(
      height: _hourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nhãn giờ — ẩn "00:00" như week view
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 0, right: 8),
              child: Transform.translate(
                // Dịch lên trên để label nằm TRÊN đường kẻ
                offset: const Offset(0, -8),
                child: Text(
                  hour == 0 ? '' : '${hour.toString().padLeft(2, '0')}:00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Đường kẻ dọc phân cách
          Container(width: 1, color: AppColors.border.withOpacity(0.4)),

          // Khu vực sự kiện
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),
              // TODO: Render events theo giờ ở đây
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeLine(DateTime now) {
    // Tính vị trí pixel của giờ hiện tại
    final minuteOffset =
        now.hour * _hourHeight + (now.minute / 60) * _hourHeight;

    return Positioned(
      top: minuteOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 52,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
              ),
            ),
          ),
          // Đường kẻ đỏ ngang
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.error.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
