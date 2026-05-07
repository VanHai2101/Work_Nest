import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

class GetCalendarEventsParams {
  final DateTime start;
  final DateTime end;

  GetCalendarEventsParams({required this.start, required this.end});
}

class GetCalendarEventsUseCase implements StreamUseCase<List<CalendarEvent>, GetCalendarEventsParams> {
  final ICalendarRepository _repository;

  GetCalendarEventsUseCase(this._repository);

  @override
  Stream<List<CalendarEvent>> call(GetCalendarEventsParams params) {
    return _repository.getEvents(params.start, params.end);
  }
}
