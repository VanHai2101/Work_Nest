import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_events.dart';

import 'cal_repo_providers.dart';

final getCalendarEventsUseCaseProvider = Provider<GetCalendarEventsUseCase>((ref) {
  return GetCalendarEventsUseCase(ref.watch(calendarRepositoryProvider));
});
