import 'package:work_nest/core/usecases/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

class GetUserNotificationsUseCase implements StreamUseCase<List<NotificationEntity>, String> {
  final INotificationRepository _repository;

  GetUserNotificationsUseCase(this._repository);

  @override
  Stream<List<NotificationEntity>> call(String userId) {
    return _repository.getUserNotifications(userId);
  }
}
