import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

class PaymentsNotifier extends StateNotifier<AsyncValue<List<PaymentModel>>> {
  final PaymentService _service;
  final String? membershipId;

  PaymentsNotifier(this._service, this.membershipId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getPayments(membershipId: membershipId);
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addPayment(Map<String, dynamic> data) async {
    final result = await _service.addPayment(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> markPaid(String id) async {
    final result = await _service.markPaid(id);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, AsyncValue<List<PaymentModel>>>(
  (ref) => PaymentsNotifier(ref.read(paymentServiceProvider), null),
);

final paymentsForMembershipProvider =
    FutureProvider.family<List<PaymentModel>, String>((ref, membershipId) async {
  final service = ref.read(paymentServiceProvider);
  final result = await service.getPayments(membershipId: membershipId);
  if (result.success) return result.data ?? [];
  throw Exception(result.message);
});
