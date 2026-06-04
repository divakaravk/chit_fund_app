import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationService _service;

  NotificationsNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getNotifications();
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<void> markRead(String id) async {
    await _service.markRead(id);
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((n) => n.id == id
            ? NotificationModel(
                id: n.id,
                userId: n.userId,
                title: n.title,
                body: n.body,
                type: n.type,
                isRead: true,
                referenceId: n.referenceId,
                createdAt: n.createdAt,
              )
            : n).toList(),
      );
    });
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
    state.whenData((list) {
      state = AsyncValue.data(list.where((n) => n.id != id).toList());
    });
  }

  int get unreadCount {
    return state.when(
      data: (list) => list.where((n) => !n.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>(
  (ref) => NotificationsNotifier(ref.read(notificationServiceProvider)),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).when(
        data: (list) => list.where((n) => !n.isRead).length,
        loading: () => 0,
        error: (_, __) => 0,
      );
});
