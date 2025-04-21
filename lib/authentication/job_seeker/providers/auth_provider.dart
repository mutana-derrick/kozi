import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/services/api_service.dart';

// Provider for the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.userId,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    String? userId,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState()) {
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
      
      final result = await _apiService.loginJobSeeker(email, password);
      
      if (result['success']) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: result['data']['userId']?.toString(),
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
      
      final result = await _apiService.signupJobSeeker(userData);
      
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
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});