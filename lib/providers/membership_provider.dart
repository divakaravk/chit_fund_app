import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/membership_model.dart';
import '../services/membership_service.dart';

final membershipServiceProvider = Provider((ref) => MembershipService());

final membershipsProvider =
    FutureProvider.family<List<MembershipModel>, String?>((ref, groupId) async {
  final service = ref.read(membershipServiceProvider);
  final result = await service.getMemberships(groupId: groupId);
  if (result.success) return result.data ?? [];
  throw Exception(result.message);
});

class MembershipsNotifier extends StateNotifier<AsyncValue<List<MembershipModel>>> {
  final MembershipService _service;
  final String? groupId;

  MembershipsNotifier(this._service, this.groupId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getMemberships(groupId: groupId);
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addMembership(Map<String, dynamic> data) async {
    final result = await _service.addMembership(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}
