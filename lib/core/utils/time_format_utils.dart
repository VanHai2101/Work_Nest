import '../constants/index.dart';

/// Time formatting utilities
/// Reusable methods for formatting dates and times
class TimeFormatUtils {
  /// Format time difference as human-readable string
  /// Returns: 'now', '5m', '2h', '3d'
  static String formatTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return AppStrings.now;
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}${AppStrings.minuteShort}';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}${AppStrings.hourShort}';
    } else {
      return '${diff.inDays}${AppStrings.dayShort}';
    }
  }

  /// Format DateTime to time string (HH:mm)
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to date string (dd/MM/yyyy)
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  /// Format DateTime to full string (dd/MM/yyyy HH:mm)
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Format duration for call timer (HH:mm:ss)
  static String formatDuration(Duration duration) {
    final hours = (duration.inSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((duration.inSeconds ~/ 60) % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
