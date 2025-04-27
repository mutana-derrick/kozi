import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/dashboard/job_seeker/providers/dashboard_providers.dart';
import 'package:kozi/dashboard/job_seeker/providers/jobs_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_bottom_navbar.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_header.dart';
import 'package:kozi/dashboard/job_seeker/widgets/job_card_widget.dart'; // Import the new widget
import 'package:kozi/shared/advertisement_carousel.dart';

class SeekerDashboardScreen extends ConsumerWidget {
  const SeekerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user profile data from API
    final userProfileAsync = ref.watch(dashboardProfileProvider);
    // Watch profile completion progress from API
    final profileProgressAsync = ref.watch(profileProgressProvider);
    // Watch available jobs from API
    // ignore: unused_local_variable
    final jobsAsync = ref.watch(dashboardJobsProvider);

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
              const CustomHeader(title: 'Home'),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh all data and await the results
                    await Future.wait([
                      ref.refresh(dashboardProfileProvider.future),
                      ref.refresh(profileProgressProvider.future),
                      ref.refresh(dashboardJobsProvider.future),
                    ]);
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting section with user's name
                        userProfileAsync.when(
                          data: (userProfile) {
                            final userName =
                                userProfile?['first_name'] ?? 'User';
                            return _buildGreeting(userName);
                          },
                          loading: () => _buildGreeting('User'),
                          error: (_, __) => _buildGreeting('User'),
                        ),
                        const SizedBox(height: 16),

                        // Profile card with user data
                        userProfileAsync.when(
                          data: (userProfile) {
                            if (userProfile == null) {
                              return _buildProfileCardSkeleton(context, ref);
                            }

                            return _buildProfileCard(
                              context,
                              ref,
                              name:
                                  "${userProfile['first_name'] ?? ''} ${userProfile['last_name'] ?? ''}",
                              age: _calculateAge(userProfile['date_of_birth']),
                              location:
                                  "${userProfile['sector'] ?? ''}, ${userProfile['district'] ?? ''}",
                              specialization:
                                  userProfile['bio'] ?? 'Update your profile',
                              rating:
                                  5, // Hardcoded since API doesn't provide rating
                              imageUrl: userProfile['image'] ?? '',
                            );
                          },
                          loading: () =>
                              _buildProfileCardSkeleton(context, ref),
                          error: (_, __) =>
                              _buildProfileCardSkeleton(context, ref),
                        ),

                        const SizedBox(height: 16),

                        // Row with section title and More button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Open Jobs Opportunities!'),
                            TextButton(
                              onPressed: () {
                                // Update the selected nav index to Jobs (index 1)
                                ref.read(selectedNavIndex.notifier).state = 1;
                                // Navigate to jobs screen
                                context.go('/jobs');
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'See all',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Job listings from API
                        ref.watch(apiJobsProvider).when(
                              data: (jobs) {
                                if (jobs.isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text(
                                        'No jobs available at the moment. Please check back later.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Display up to 3 jobs on the dashboard
                                final displayJobs =
                                    jobs.length > 3 ? jobs.sublist(0, 3) : jobs;

                                return Column(
                                  children: displayJobs
                                      .map((job) => JobCardWidget(
                                            job: job,
                                            onApplyPressed: () {
                                              context.push('/job/${job.id}');
                                            },
                                          ))
                                      .toList(),
                                );
                              },
                              loading: () => Center(
                                child: Column(
                                  children: List.generate(2,
                                      (index) => const JobCardSkeletonWidget()),
                                ),
                              ),
                              error: (_, __) => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    'Failed to load jobs. Pull down to refresh.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            ),

                        const SizedBox(height: 16),

                        // Advertisement carousel
                        const AdvertisementCarousel(),

                        const SizedBox(height: 16),

                        // Profile completion progress card
                        profileProgressAsync.when(
                          data: (progress) =>
                              _buildCompletionCard(context, ref, progress),
                          loading: () => _buildCompletionCard(context, ref, 0),
                          error: (_, __) =>
                              _buildCompletionCard(context, ref, 0),
                        ),
                      ],
                    ),
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

  // Calculate age from date of birth string
  int _calculateAge(String? dateOfBirth) {
    if (dateOfBirth == null ||
        dateOfBirth.isEmpty ||
        dateOfBirth == 'DD/MM/YYYY') {
      return 0;
    }

    try {
      // Parse the date string (format: DD/MM/YYYY)
      final parts = dateOfBirth.split('/');
      if (parts.length != 3) return 0;

      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? 2000;

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age < 0 ? 0 : age;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildGreeting(String name) {
    return Text(
      'Good Day, $name!',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required int age,
    required String location,
    required String specialization,
    required int rating,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    '$baseApiUrl/uploads/$imageUrl',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
          const SizedBox(width: 16),

          // Profile details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      color: Colors.pink,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'I am ${age > 0 ? '$age years old' : ''}, I live in $location and specialize in $specialization',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        Icons.star,
                        color: i < rating ? Colors.amber : Colors.grey,
                        size: 16,
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to profile page
                        context.go('/seekerprofile');
                        ref.read(selectedNavIndex.notifier).state = 4;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA60A7),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Update'),
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

  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFF4CE5B1),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildProfileCardSkeleton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Skeleton profile image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Skeleton profile details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to profile page
                        context.go('/seekerprofile');
                        ref.read(selectedNavIndex.notifier).state = 4;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA60A7),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Update'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Pass WidgetRef ref as a parameter to this method
  Widget _buildCompletionCard(
      BuildContext context, WidgetRef ref, int progressPercentage) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Completion',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressPercentage < 100
                ? 'Complete your profile to increase your chances of being hired!'
                : 'Your profile is complete! You are ready to be hired.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFEA60A7)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$progressPercentage% Complete',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEA60A7),
            ),
          ),
          const SizedBox(height: 16),

          // Action button based on completion status
          if (progressPercentage < 100)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go('/seekerprofile');
                  ref.read(selectedNavIndex.notifier).state = 4;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Complete your profile'),
              ),
            )
          else
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.go('/payment');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pay registration fees'),
              ),
            ),
        ],
      ),
    );
  }

  // Add a constant for the base API URL
  static const String baseApiUrl =
      'http://192.168.0.105:3000'; // Change this to your actual API base URL
}
