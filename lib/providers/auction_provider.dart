import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';
import '../services/auction_service.dart';

final auctionServiceProvider = Provider((ref) => AuctionService());

final auctionsProvider =
    FutureProvider.family<List<AuctionModel>, String?>((ref, groupId) async {
  final service = ref.read(auctionServiceProvider);
  final result = await service.getAuctions(groupId: groupId);
  if (result.success) return result.data ?? [];
  throw Exception(result.message);
});

final bidsProvider = FutureProvider.family<List<BidModel>, String>((ref, auctionId) async {
  final service = ref.read(auctionServiceProvider);
  final result = await service.getBids(auctionId);
  if (result.success) return result.data ?? [];
  throw Exception(result.message);
});

class AuctionsNotifier extends StateNotifier<AsyncValue<List<AuctionModel>>> {
  final AuctionService _service;
  final String? groupId;

  AuctionsNotifier(this._service, this.groupId) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getAuctions(groupId: groupId);
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addAuction(Map<String, dynamic> data) async {
    final result = await _service.addAuction(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> closeAuction(String id, Map<String, dynamic> data) async {
    final result = await _service.closeAuction(id, data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}
