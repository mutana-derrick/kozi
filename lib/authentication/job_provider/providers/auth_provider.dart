import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/services/api_service.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth state model
class ProviderAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;

  ProviderAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
  });

  ProviderAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? userId,
  }) {
    return ProviderAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
    );
  }
}

// Auth notifier
class ProviderAuthNotifier extends StateNotifier<ProviderAuthState> {
  final ApiService _apiService;

  ProviderAuthNotifier(this._apiService) : super(ProviderAuthState()) {
    // Check if user is already logged in when initialized
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _apiService.isLoggedIn();
    final userId = await _apiService.getUserId();

    state = state.copyWith(
      isAuthenticated: isLoggedIn,
      userId: userId,
    );
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _apiService.loginJobProvider(email, password);

      if (result['success']) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: result['userId']?.toString(),
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: result['message'],
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final result = await _apiService.signupJobProvider(userData);

      if (result['success']) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'],
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    state = state.copyWith(isAuthenticated: false, userId: null);
  }
}

// Provider for auth state
final providerAuthProvider =
    StateNotifierProvider<ProviderAuthNotifier, ProviderAuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProviderAuthNotifier(apiService);
});
