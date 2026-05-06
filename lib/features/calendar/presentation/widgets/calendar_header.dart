import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_nest/core/theme/index.dart';
import 'package:work_nest/core/extensions/index.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../providers/calendar_provider.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({super.key});

  String _getDateString(CalendarViewMode mode, DateTime focused, DateTime? selected) {
    switch (mode) {
      case CalendarViewMode.day:
        final date = selected ?? focused;
        return '${date.day} Tháng ${date.month}, ${date.year}';
      case CalendarViewMode.week:
        final date = selected ?? focused;
        final week = date.daysInWeek;
        final start = week.first;
        final end = week.last;
        if (start.month == end.month) {
          return '${start.day}-${end.day} Thg ${start.month}, ${start.year}';
        } else {
          return '${start.day}/${start.month} - ${end.day}/${end.month}, ${start.year}';
        }
      case CalendarViewMode.month:
        return 'Tháng ${focused.month} ${focused.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final focused = state.focusedMonth;
    final selected = state.selectedDay;

    final userProfile = ref.watch(userProfileProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          if (isWide) {
            return Row(
              children: [
                _buildDateText(state.viewMode, focused, selected),
                const SizedBox(width: 24),
                _buildNavigation(state, notifier, focused, selected),
                const Spacer(),
                _buildUserSelector(userProfile.asData?.value, isMini: false),
                const SizedBox(width: 12),
                _buildViewSwitcher(state, notifier),
              ],
            );
          } else {
            // Narrow layout (2 rows)
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateText(state.viewMode, focused, selected, isMini: true),
                    ),
                    const SizedBox(width: 8),
                    _buildNavigation(state, notifier, focused, selected, isMini: true),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildUserSelector(userProfile.asData?.value, isMini: true),
                    ),
                    const SizedBox(width: 8),
                    _buildViewSwitcher(state, notifier, isMini: true),
                  ],
                ),

              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDateText(CalendarViewMode mode, DateTime focused, DateTime? selected, {bool isMini = false}) {
    return Text(
      _getDateString(mode, focused, selected),
      style: TextStyle(
        fontSize: isMini ? 14 : 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNavigation(CalendarState state, CalendarNotifier notifier, DateTime focused, DateTime? selected, {bool isMini = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: state.viewMode == CalendarViewMode.month 
              ? notifier.goToPreviousMonth 
              : () => notifier.selectDay((selected ?? focused).subtract(const Duration(days: 1))),
          isMini: isMini,
        ),
        SizedBox(width: isMini ? 4 : 8),
        GestureDetector(
          onTap: notifier.goToToday,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isMini ? 8 : 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'HÔM NAY',
              style: TextStyle(
                fontSize: isMini ? 9 : 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.black54,
              ),
            ),
          ),
        ),
        SizedBox(width: isMini ? 4 : 8),
        _NavIconButton(
          icon: Icons.chevron_right_rounded,
          onTap: state.viewMode == CalendarViewMode.month 
              ? notifier.goToNextMonth 
              : () => notifier.selectDay((selected ?? focused).add(const Duration(days: 1))),
          isMini: isMini,
        ),
      ],
    );
  }

  Widget _buildUserSelector(UserEntity? user, {bool isMini = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMini ? 8 : 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: isMini ? 8 : 10,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Icon(Icons.person, size: isMini ? 10 : 12, color: Colors.grey)
                : null,
          ),
          SizedBox(width: isMini ? 6 : 8),
          Flexible(
            child: Text(
              user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: isMini ? 10 : 12,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          const SizedBox(width: 4),
          Icon(Icons.unfold_more, size: isMini ? 12 : 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildViewSwitcher(CalendarState state, CalendarNotifier notifier, {bool isMini = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            label: 'NGÀY',
            isSelected: state.viewMode == CalendarViewMode.day,
            onTap: () => notifier.setViewMode(CalendarViewMode.day),
            isMini: isMini,
          ),
          _PillButton(
            label: 'TUẦN',
            isSelected: state.viewMode == CalendarViewMode.week,
            onTap: () => notifier.setViewMode(CalendarViewMode.week),
            isMini: isMini,
          ),
          _PillButton(
            label: 'THÁNG',
            isSelected: state.viewMode == CalendarViewMode.month,
            onTap: () => notifier.setViewMode(CalendarViewMode.month),
            isMini: isMini,
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isMini;

  const _NavIconButton({required this.icon, required this.onTap, this.isMini = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black54, size: isMini ? 18 : 20),
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isMini;

  const _PillButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isMini ? 8 : 16, vertical: 8),

        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isMini ? 8 : 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.blue : Colors.black54,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

