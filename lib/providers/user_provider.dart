import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider((ref) => UserService());

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final service = ref.read(userServiceProvider);
  final result = await service.getUsers();
  if (result.success) return result.data ?? [];
  throw Exception(result.message);
});

final userDetailProvider = FutureProvider.family<UserModel, String>((ref, id) async {
  final service = ref.read(userServiceProvider);
  final result = await service.getUserById(id);
  if (result.success) return result.data!;
  throw Exception(result.message);
});

class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserService _service;

  UsersNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getUsers();
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addUser(Map<String, dynamic> data) async {
    final result = await _service.addUser(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deactivateUser(String id) async {
    final result = await _service.patchUserStatus(id, 'inactive');
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}

final usersNotifierProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>(
  (ref) => UsersNotifier(ref.read(userServiceProvider)),
);
