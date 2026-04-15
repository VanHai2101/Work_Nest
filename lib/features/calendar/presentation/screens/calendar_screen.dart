import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import '../providers/calendar_provider.dart';
import '../widgets/calendar_header.dart';
import '../widgets/calendar_month.dart';
import '../widgets/calendar_week.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/calendar_event.dart';
import '../../data/repositories/firebase_calendar_repository.dart';
import '../widgets/calendar_day.dart';


class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: tiêu đề tháng + điều hướng + chuyển chế độ xem ──
            const CalendarHeader(),

            const SizedBox(height: 8),

            // ── Phần nội dung chính theo chế độ xem ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _buildBody(
                  state.viewMode,
                  key: ValueKey(state.viewMode),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── FAB: Thêm sự kiện mới ──
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // -- TÌM MỘT PROJECT ID CÓ SẴN CỦA USER ĐỂ TEST --
            final uid = ref.read(calendarRepositoryProvider); // Lấy ref provider
            
            // Do cần import FirebaseAuth / Firestore, thay vì parse phức tạp,
            // mình mở màn hình nhắc nhở để user đổi sang form thật.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tính năng test đã khoá. Vui lòng thêm Task từ trang công việc của Project để đúng chuẩn dữ liệu!'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            return;
            
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildBody(CalendarViewMode mode, {required Key key}) {
    switch (mode) {
      case CalendarViewMode.month:
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CalendarMonthGrid(),
        );
      case CalendarViewMode.week:
        return Padding(
          key: key,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CalendarWeekView(),
        );
      case CalendarViewMode.day:
        return CalendarDayView(key: key);
    }
  }
}

class _ComingSoonView extends StatelessWidget {
  final String label;
  const _ComingSoonView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_view_week_rounded,
          size: 64,
          color: AppColors.textTertiary,
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sắp ra mắt',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
        ),
      ],
    );
  }
}
