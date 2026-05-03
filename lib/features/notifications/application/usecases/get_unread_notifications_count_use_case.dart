import 'package:work_nest/core/usecases/usecase.dart';
import 'package:work_nest/features/notifications/domain/repositories/index.dart';

class GetUnreadNotificationsCountUseCase implements StreamUseCase<int, String> {
  final INotificationRepository _repository;

  GetUnreadNotificationsCountUseCase(this._repository);

  @override
  Stream<int> call(String userId) {
    return _repository.getUnreadCount(userId);
  }
}
