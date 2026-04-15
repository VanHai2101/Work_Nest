import '../entities/calendar_event.dart';

abstract class ICalendarRepository {
  /// Lấy danh sách sự kiện trong một khoảng thời gian
  Stream<List<CalendarEvent>> getEvents(DateTime start, DateTime end);
  
  /// Thêm sự kiện mới
  Future<void> addEvent(CalendarEvent event);
  
  /// Cập nhật sự kiện
  Future<void> updateEvent(CalendarEvent event);
  
  /// Xóa sự kiện
  Future<void> deleteEvent(String id);
}
