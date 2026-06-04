import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/local_storage.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AuthState());

  Future<bool> checkAuth() async {
    final loggedIn = await LocalStorage.isLoggedIn();
    state = state.copyWith(isLoggedIn: loggedIn);
    return loggedIn;
  }

  Future<bool> login({
    required String companyCode,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _service.login(
      companyCode: companyCode,
      phone: phone,
      role: role,
    );
    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        user: result.data,
        isLoggedIn: true,
      );
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.message);
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState();
  }
}

final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);
