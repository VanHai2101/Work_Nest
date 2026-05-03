import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/usecases/watch_incoming_calls_use_case.dart';
import '../../application/usecases/start_call_use_case.dart';
import '../../application/usecases/accept_call_use_case.dart';
import '../../application/usecases/end_call_use_case.dart';
import '../../application/usecases/reject_call_use_case.dart';
import '../../application/usecases/watch_call_use_case.dart';
import 'call_repository_providers.dart';

final watchIncomingCallsUseCaseProvider = Provider<WatchIncomingCallsUseCase>((ref) {
  return WatchIncomingCallsUseCase(ref.watch(callRepositoryProvider));
});

final startCallUseCaseProvider = Provider<StartCallUseCase>((ref) {
  return StartCallUseCase(ref.watch(callRepositoryProvider));
});

final acceptCallUseCaseProvider = Provider<AcceptCallUseCase>((ref) {
  return AcceptCallUseCase(ref.watch(callRepositoryProvider));
});

final endCallUseCaseProvider = Provider<EndCallUseCase>((ref) {
  return EndCallUseCase(ref.watch(callRepositoryProvider));
});

final rejectCallUseCaseProvider = Provider<RejectCallUseCase>((ref) {
  return RejectCallUseCase(ref.watch(callRepositoryProvider));
});

final watchCallUseCaseProvider = Provider<WatchCallUseCase>((ref) {
  return WatchCallUseCase(ref.watch(callRepositoryProvider));
});
