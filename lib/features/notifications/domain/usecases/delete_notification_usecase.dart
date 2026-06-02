// lib/features/notifications/domain/usecases/delete_notification_usecase.dart
import '../repositories/notification_repository.dart';

class DeleteNotificationUsecase {
  final NotificationRepository repository;
  DeleteNotificationUsecase(this.repository);

  /// Delete by index (legacy — avoid using this due to race conditions)
  Future<void> call(int key) async {
    return await repository.delete(key);
  }

  /// Delete by Firestore document ID (preferred)
  Future<void> byId(String id) async {
    return await repository.deleteById(id);
  }
}
