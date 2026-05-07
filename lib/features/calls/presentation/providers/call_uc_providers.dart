import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/watch_incoming.dart';
import '../../domain/usecases/start_call.dart';
import '../../domain/usecases/accept_call.dart';
import '../../domain/usecases/end_call.dart';
import '../../domain/usecases/reject_call.dart';
import '../../domain/usecases/watch_call.dart';

import 'call_repo_providers.dart';

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
