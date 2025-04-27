import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/dashboard/job_seeker/models/job.dart';
import 'package:kozi/dashboard/job_seeker/providers/jobs_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_bottom_navbar.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_header.dart';
import 'dart:math' as math;

import 'package:kozi/utils/text_utils.dart';

// Define a provider to track favorite jobs
final favoritesProvider = StateProvider<Set<String>>((ref) => {});

// Provider for jobs filter
final jobFilterProvider = StateProvider<String>((ref) => 'All Categories');

// Provider for jobs search query
final jobSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for filtered jobs
final filteredJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(jobsProvider);
  final filter = ref.watch(jobFilterProvider);
  final searchQuery = ref.watch(jobSearchQueryProvider).toLowerCase();

  // Apply filters
  return jobs.where((job) {
    // Apply category filter
    final matchesCategory =
        filter == 'All Categories' || job.category == filter;

    // Apply search query filter
    final matchesQuery = searchQuery.isEmpty ||
        job.title.toLowerCase().contains(searchQuery) ||
        job.description.toLowerCase().contains(searchQuery) ||
        job.company.toLowerCase().contains(searchQuery);

    return matchesCategory && matchesQuery;
  }).toList();
});

// Provider for job application loading state
final jobApplyingProvider = StateProvider<bool>((ref) => false);

// Provider for job application error message
final jobApplyErrorProvider = StateProvider<String?>((ref) => null);

class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isFilterExpanded = false;

  // Static list of categories (this would come from API later)
  final List<String> _categories = [
    'All Categories',
    'Healthcare',
    'Technology',
    'Education',
    'Hospitality',
    'Construction',
    'Office Work',
    'Retail',
    'Food Service'
  ];

  @override
  void initState() {
    super.initState();
    // Refresh job listings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the discard operator (_) to explicitly ignore the return value
      final _ = ref.refresh(apiJobsProvider);
    });

    // Set controller text based on provider
    _searchController.text = ref.read(jobSearchQueryProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read providers for UI state
    final filteredJobs = ref.watch(filteredJobsProvider);
    final favorites = ref.watch(favoritesProvider);
    // ignore: unused_local_variable
    final isLoading = ref.watch(jobApplyingProvider);
    final errorMessage = ref.watch(jobApplyErrorProvider);

    // Sort jobs with favorites first
    filteredJobs.sort((a, b) {
      if (favorites.contains(a.id) && !favorites.contains(b.id)) {
        return -1; // a comes before b
      } else if (!favorites.contains(a.id) && favorites.contains(b.id)) {
        return 1; // b comes before a
      } else {
        return 0; // no change in order
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: [
                Color(0xFFF8BADC),
                Color.fromARGB(255, 250, 240, 245),
              ],
            ),
          ),
          child: Column(
            children: [
              const CustomHeader(title: 'Jobs'),

              // Error message if any
              if (errorMessage != null)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          ref.read(jobApplyErrorProvider.notifier).state = null;
                        },
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Open Jobs Opportunities!'),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'All Categories',
                            isSelected: ref.watch(jobFilterProvider) ==
                                'All Categories',
                            onTap: () {
                              ref.read(jobFilterProvider.notifier).state =
                                  'All Categories';
                              setState(() {
                                _isFilterExpanded = false;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildFilterButton(
                            label: 'Categories',
                            isActive: ref.watch(jobFilterProvider) !=
                                'All Categories',
                            isExpanded: _isFilterExpanded,
                            onTap: () {
                              setState(() {
                                _isFilterExpanded = !_isFilterExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded filter content if filter is expanded
              if (_isFilterExpanded)
                Container(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories
                        .where((c) => c != 'All Categories')
                        .map((category) {
                      return _buildFilterOptionChip(
                        label: category,
                        isSelected: ref.watch(jobFilterProvider) == category,
                        onTap: () {
                          final currentFilter = ref.read(jobFilterProvider);
                          ref.read(jobFilterProvider.notifier).state =
                              currentFilter == category
                                  ? 'All Categories'
                                  : category;
                        },
                      );
                    }).toList(),
                  ),
                ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Use the discard operator (_) to explicitly ignore the return value
                    final _ = await ref.refresh(apiJobsProvider.future);
                  },
                  child: filteredJobs.isEmpty
                      ? const Center(
                          child: Text(
                            'No jobs found matching your criteria',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) =>
                              _buildJobCard(context, filteredJobs[index]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFFEA60A7)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(jobSearchQueryProvider.notifier).state = value;
              },
              decoration: const InputDecoration(
                hintText: 'Search for jobs...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                ref.read(jobSearchQueryProvider.notifier).state = '';
              },
            ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                // Force a refresh with current search term
                final searchTerm = _searchController.text;
                ref.read(jobSearchQueryProvider.notifier).state = searchTerm;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA60A7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pink[300]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.pink[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.pink[300]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.pink[700] : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isActive ? Colors.pink[700] : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[300] : Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.pink[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Apply for job method
  Future<void> _applyForJob(BuildContext context, String jobId) async {
    // Clear any previous error
    ref.read(jobApplyErrorProvider.notifier).state = null;

    // Set loading state
    ref.read(jobApplyingProvider.notifier).state = true;

    try {
      // Get API service
      final apiService = ref.read(apiServiceProvider);

      // Call apply for job API
      final result = await apiService.applyForJob(jobId);

      // Update loading state
      ref.read(jobApplyingProvider.notifier).state = false;

      if (result['success']) {
        // Navigate to job details / application form
        if (context.mounted) {
          context.push('/apply/$jobId/form');
        }
      } else {
        // Show error
        ref.read(jobApplyErrorProvider.notifier).state =
            result['message'] ?? 'Failed to apply for job';
      }
    } catch (e) {
      // Handle error
      ref.read(jobApplyingProvider.notifier).state = false;
      ref.read(jobApplyErrorProvider.notifier).state = 'Error: $e';
    }
  }

  Widget _buildJobCard(BuildContext context, Job job) {
    // Get favorite status from provider
    final isFavorite = ref.watch(favoritesProvider).contains(job.id);
    final isLoading = ref.watch(jobApplyingProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: job.companyLogoColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                job.companyLogo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Interactive heart icon
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        final favoritesNotifier =
                            ref.read(favoritesProvider.notifier);
                        final favorites = ref.read(favoritesProvider);

                        if (isFavorite) {
                          // Remove from favorites
                          favoritesNotifier.state = {...favorites}
                            ..remove(job.id);
                        } else {
                          // Add to favorites
                          favoritesNotifier.state = {...favorites, job.id};
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  TextUtils.cleanHtmlText(job.description),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (job.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        job.location!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row with rating/views or deadline
                    Row(
                      children: [
                        // Job deadline if available
                        if (job.deadlineDate != null) ...[
                          const Icon(
                            Icons.timer,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Due: ${_formatDeadlineDate(job.deadlineDate!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${job.rating}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '(${job.views} views)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Second row with the apply button positioned at the right
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  // First view the job details
                                  context.push('/job/${job.id}');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA60A7),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Apply for this job',
                                  style: TextStyle(fontSize: 12),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDeadlineDate(String dateString) {
  try {
    // Check if the date contains 'T' which suggests ISO format
    if (dateString.contains('T')) {
      // Split by T to get date part
      final datePart = dateString.split('T')[0];
      // Parse the date part (should be in YYYY-MM-DD format)
      final parts = datePart.split('-');
      if (parts.length == 3) {
        // Format as YYYY-MM-DD
        return '${parts[0]}-${parts[1]}-${parts[2]}';
      }
    }

    // If we couldn't parse it, just return a cleaner version
    return dateString
        .replaceAll('T', ' ')
        .substring(0, math.min(10, dateString.length));
  } catch (e) {
    // If any parsing fails, return at most first 10 chars
    if (dateString.length > 10) {
      return dateString.substring(0, 10);
    }
    return dateString;
  }
}
