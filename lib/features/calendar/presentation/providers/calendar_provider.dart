import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CalendarViewMode { day, week, month }

class CalendarState {
  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final CalendarViewMode viewMode;

  const CalendarState({
    required this.focusedMonth,
    this.selectedDay,
    this.viewMode = CalendarViewMode.month,
  });

  CalendarState copyWith({
    DateTime? focusedMonth,
    DateTime? selectedDay,
    CalendarViewMode? viewMode,
    bool clearSelectedDay = false,
  }) {
    return CalendarState(
      focusedMonth: focusedMonth ?? this.focusedMonth,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier()
      : super(CalendarState(
          focusedMonth: DateTime.now(),
          selectedDay: DateTime.now(),
        ));

  void goToPreviousMonth() {
    final current = state.focusedMonth;
    state = state.copyWith(
      focusedMonth: DateTime(current.year, current.month - 1, 1),
    );
  }

  void goToNextMonth() {
    final current = state.focusedMonth;
    state = state.copyWith(
      focusedMonth: DateTime(current.year, current.month + 1, 1),
    );
  }

  void goToToday() {
    final today = DateTime.now();
    state = state.copyWith(
      focusedMonth: DateTime(today.year, today.month, 1),
      selectedDay: today,
    );
  }

  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  void setViewMode(CalendarViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>(
  (ref) => CalendarNotifier(),
);
