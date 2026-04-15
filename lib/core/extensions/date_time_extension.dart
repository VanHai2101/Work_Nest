import 'package:flutter/material.dart';

extension DateTimeX on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  bool get isSunday => weekday == DateTime.sunday;

  /// Trả về danh sách 7 ngày trong tuần chứa ngày này (bắt đầu từ Thứ 2)
  List<DateTime> get daysInWeek {
    final startOfWeek = subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  /// Format tên Thứ sang Tiếng Việt
  String get weekdayNameVi {
    switch (weekday) {
      case 1: return 'Thứ 2';
      case 2: return 'Thứ 3';
      case 3: return 'Thứ 4';
      case 4: return 'Thứ 5';
      case 5: return 'Thứ 6';
      case 6: return 'Thứ 7';
      case 7: return 'CN';
      default: return '';
    }
  }

  /// Tên Thứ đầy đủ
  String get weekdayFullVi => weekday == 7 ? 'Chủ nhật' : 'Thứ $weekday';
}
