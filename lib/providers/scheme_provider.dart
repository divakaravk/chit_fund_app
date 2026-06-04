import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scheme_model.dart';
import '../services/scheme_service.dart';

final schemeServiceProvider = Provider((ref) => SchemeService());

class SchemesNotifier extends StateNotifier<AsyncValue<List<SchemeModel>>> {
  final SchemeService _service;

  SchemesNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _service.getSchemes();
    if (result.success) {
      state = AsyncValue.data(result.data ?? []);
    } else {
      state = AsyncValue.error(result.message ?? 'Error', StackTrace.current);
    }
  }

  Future<bool> addScheme(Map<String, dynamic> data) async {
    final result = await _service.addScheme(data);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> deleteScheme(String id) async {
    final result = await _service.deleteScheme(id);
    if (result.success) {
      await load();
      return true;
    }
    return false;
  }
}

final schemesProvider =
    StateNotifierProvider<SchemesNotifier, AsyncValue<List<SchemeModel>>>(
  (ref) => SchemesNotifier(ref.read(schemeServiceProvider)),
);
