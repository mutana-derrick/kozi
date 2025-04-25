// lib/dashboard/job_seeker/providers/dashboard_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';

// Provider for user profile data on the dashboard
final dashboardProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final userId = await apiService.getUserId();

  if (userId == null) {
    return null;
  }

  try {
    final result = await apiService.getUserProfile(userId);
    if (result['success']) {
      return result['data'];
    }
    return null;
  } catch (e) {
    print('Error fetching profile for dashboard: $e');
    return null;
  }
});

// Provider for user profile completion progress
final profileProgressProvider = FutureProvider.autoDispose<int>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final userId = await apiService.getUserId();

  if (userId == null) {
    return 0;
  }

  try {
    // Use the progress endpoint to get completion percentage
    final response = await apiService.getProfileProgress(userId);
    if (response['success']) {
      return response['progress'] ?? 0;
    }
    return 0;
  } catch (e) {
    print('Error fetching profile progress: $e');
    return 0;
  }
});

// Provider for job listings on the dashboard
final dashboardJobsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  try {
    final jobs = await apiService.getJobs();
    return jobs;
  } catch (e) {
    print('Error fetching jobs for dashboard: $e');
    return [];
  }
});