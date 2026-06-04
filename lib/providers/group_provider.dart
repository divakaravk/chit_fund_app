import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';

final groupServiceProvider = Provider((ref) => GroupService());

class GroupsNotifier extends StateNotifier<AsyncValue<List<GroupModel>>> {
  final GroupService _service;

  GroupsNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getGroups();
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addGroup(Map<String, dynamic> data) async {
    final result = await _service.addGroup(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, AsyncValue<List<GroupModel>>>(
  (ref) => GroupsNotifier(ref.read(groupServiceProvider)),
);

final groupDetailProvider = FutureProvider.family<GroupModel, String>((ref, id) async {
  final service = ref.read(groupServiceProvider);
  final result = await service.getGroupById(id);
  if (result.success) return result.data!;
  throw Exception(result.message);
});
