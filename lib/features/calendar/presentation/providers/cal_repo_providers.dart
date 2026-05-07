import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../../data/repositories/firebase_calendar_repository.dart';

final calendarRepositoryProvider = Provider<ICalendarRepository>((ref) {
  return FirebaseCalendarRepository();
});
