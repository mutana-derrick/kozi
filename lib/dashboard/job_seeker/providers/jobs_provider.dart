// providers/job_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job.dart';

// Provider for the list of jobs (keeping your existing data)
final jobsProvider = Provider<List<Job>>((ref) {
  return [
    Job(
      id: '001', // Added ID
      title: 'Country Manager',
      company: 'Yellow',
      description: 'Yellow\'s purpose is to make life...',
      companyLogo: 'Y',
      companyLogoColor: Colors.amber,
      rating: 2.8,
      views: 2821,
      // Added new fields to match the job application screen
      companyDescription: "Yellow's purpose is to make life better for customers living in Africa. Through a digital technology platform, Yellow creates a distributed network of sales agents to serve rural households with life-changing products and services.",
      fullDescription: "The successful candidate will be responsible for leading and managing operations in the region.",
    ),
    Job(
      id: '002', // Added ID
      title: 'Marketing Manager',
      company: 'Sanson Group',
      description: 'Sanson Group is a IT Consultan......',
      companyLogo: 'S',
      companyLogoColor: Colors.blue.shade200,
      rating: 2.8,
      views: 2821,
      // Added some sample data for the detailed view
      companyDescription: "Sanson Group is an IT Consulting firm specializing in digital transformation solutions for enterprises.",
      fullDescription: "We are looking for a Marketing Manager to lead our marketing initiatives and develop strategies to increase brand awareness.",
    ),
    Job(
      id: '003', // Added ID
      title: 'Marketing Manager',
      company: 'Sanson Group',
      description: 'Sanson Group is a IT Consultan......',
      companyLogo: 'S',
      companyLogoColor: Colors.blue.shade200,
      rating: 2.8,
      views: 2821,
      // Added some sample data for the detailed view
      companyDescription: "Sanson Group is an IT Consulting firm with offices across multiple countries.",
      fullDescription: "As a Marketing Manager, you will be responsible for developing and implementing marketing strategies to promote our services.",
    )
  ];
});

// Provider for a single job by ID
final jobDetailsProvider = Provider.family<AsyncValue<Job>, String>((ref, jobId) {
  final jobs = ref.watch(jobsProvider);
  
  // Find the job with the matching ID
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
  
  // In a real app, you would make an API call here
});