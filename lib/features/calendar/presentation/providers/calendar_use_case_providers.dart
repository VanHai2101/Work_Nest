import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/get_calendar_events_use_case.dart';
import 'calendar_repository_providers.dart';

final getCalendarEventsUseCaseProvider = Provider<GetCalendarEventsUseCase>((ref) {
  return GetCalendarEventsUseCase(ref.watch(calendarRepositoryProvider));
});
