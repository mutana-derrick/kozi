// providers/jobs_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import '../models/job.dart';

// Provider for fetching jobs from the API
final apiJobsProvider = FutureProvider.autoDispose<List<Job>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  
  try {
    final jobsData = await apiService.getJobs();
    return jobsData.map((jobData) => Job.fromApi(jobData)).toList();
  } catch (e) {
    print('Error fetching jobs: $e');
    return [];
  }
});

// Provider for favorite jobs
final favoriteJobsProvider = StateProvider<Set<String>>((ref) => {});

// Provider for the list of jobs (combining API data with local data)
final jobsProvider = Provider<List<Job>>((ref) {
  final apiJobsAsync = ref.watch(apiJobsProvider);
  
  return apiJobsAsync.when(
    data: (jobs) => jobs,
    loading: () => _getMockJobs(), // Provide mock data while loading
    error: (_, __) => _getMockJobs(), // Fallback to mock data on error
  );
});

// Provider for a single job by ID
final jobDetailsProvider = Provider.family<AsyncValue<Job>, String>((ref, jobId) {
  final jobs = ref.watch(jobsProvider);
  
  try {
    final job = jobs.firstWhere((job) => job.id == jobId);
    return AsyncValue.data(job);
  } catch (e) {
    // Return a default job if not found
    return AsyncValue.data(
      Job(
        id: jobId,
        title: 'Job Not Found',
        company: 'Unknown',
        description: 'This job posting is no longer available',
        companyLogo: '?',
        companyLogoColor: Colors.grey,
        rating: 0.0,
        views: 0,
      ),
    );
  }
});

// Mock jobs for fallback
List<Job> _getMockJobs() {
  return [
    Job(
      id: '001',
      title: 'Country Manager',
      company: 'Yellow',
      description: 'Yellow\'s purpose is to make life...',
      companyLogo: 'Y',
      companyLogoColor: Colors.amber,
      rating: 2.8,
      views: 2821,
      companyDescription: "Yellow's purpose is to make life better for customers living in Africa.",
      fullDescription: "The successful candidate will be responsible for leading and managing operations in the region.",
    ),
    Job(
      id: '002',
      title: 'Marketing Manager',
      company: 'Sanson Group',
      description: 'Sanson Group is an IT Consulting firm...',
      companyLogo: 'S',
      companyLogoColor: Colors.blue.shade200,
      rating: 2.8,
      views: 2821,
      companyDescription: "Sanson Group is an IT Consulting firm specializing in digital transformation solutions.",
      fullDescription: "We are looking for a Marketing Manager to lead our marketing initiatives.",
    ),
  ];
}