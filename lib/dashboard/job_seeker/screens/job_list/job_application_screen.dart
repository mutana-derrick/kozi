// Inside lib/dashboard/job_seeker/screens/job_list/job_application_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/dashboard/job_seeker/models/job.dart';
import 'package:kozi/dashboard/job_seeker/providers/jobs_provider.dart';
import 'package:kozi/dashboard/job_seeker/screens/job_list/job_list_screen.dart';
import 'package:kozi/shared/date_formatter.dart';
import 'package:kozi/shared/show_result_dialog.dart';
import 'package:kozi/utils/text_utils.dart';
import 'package:share_plus/share_plus.dart';

// Provider for favorite status of the current job
final currentJobFavoriteStatusProvider =
    StateProvider.family<bool, String>((ref, jobId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(jobId);
});

// Provider for application loading state
final jobApplyLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for application error message
final jobApplyErrorMessageProvider = StateProvider<String?>((ref) => null);

class JobApplicationScreen extends ConsumerWidget {
  final String jobId;

  const JobApplicationScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailsProvider(jobId));
    final isLoading = ref.watch(jobApplyLoadingProvider);
    final errorMessage = ref.watch(jobApplyErrorMessageProvider);

    return Scaffold(
      body: jobAsync.when(
        data: (job) =>
            _buildJobDetails(context, ref, job, isLoading, errorMessage),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  // Share job function to be reused
  void _shareJob(Job job) {
    final String jobTitle = job.title;
    final String companyName = job.company;

    // Create a share text with job details
    final String shareText = '''
Check out this job opportunity!

$jobTitle at $companyName

${job.description}

Apply now on Kozi!
''';

    // Launch the share dialog
    Share.share(shareText, subject: 'Job Opportunity: $jobTitle');
  }

  // Method to handle applying for a job
  Future<void> _applyForJob(
      BuildContext context, WidgetRef ref, String jobId) async {
    // Clear any previous error messages
    ref.read(jobApplyErrorMessageProvider.notifier).state = null;

    // Set loading state to true
    ref.read(jobApplyLoadingProvider.notifier).state = true;

    try {
      // Get API service from provider
      final apiService = ref.read(apiServiceProvider);

      // Call the API to apply for the job
      final result = await apiService.applyForJob(jobId);

      // Set loading state to false
      ref.read(jobApplyLoadingProvider.notifier).state = false;

      if (result['success']) {
        // Navigate to application form for additional details
        if (context.mounted) {
          context.push('/apply/$jobId/form');
        }
      } else {
        // Show error message
        ref.read(jobApplyErrorMessageProvider.notifier).state =
            result['message'] ?? 'Failed to apply for job';
      }
    } catch (e) {
      // Set loading state to false
      ref.read(jobApplyLoadingProvider.notifier).state = false;

      // Show error message
      ref.read(jobApplyErrorMessageProvider.notifier).state =
          'An error occurred: $e';
    }
  }

  Widget _buildJobDetails(BuildContext context, WidgetRef ref, Job job,
      bool isLoading, String? errorMessage) {
    final isFavorite = ref.watch(currentJobFavoriteStatusProvider(job.id));
    final apiService = ref.read(apiServiceProvider);

    return Stack(
      children: [
        // Background gradient
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
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
        ),
        SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    const Text(
                      'Job Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => _shareJob(job),
                    ),
                  ],
                ),
              ),

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
                          ref
                              .read(jobApplyErrorMessageProvider.notifier)
                              .state = null;
                        },
                      ),
                    ],
                  ),
                ),

              // Main content with job details - Using Expanded with SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Company Logo
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

                                // Job Title and Favorite
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              job.title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // Favorite icon with toggle functionality
                                          GestureDetector(
                                            onTap: () {
                                              final favorites =
                                                  ref.read(favoritesProvider);
                                              final favoritesNotifier =
                                                  ref.read(favoritesProvider
                                                      .notifier);

                                              if (isFavorite) {
                                                // Remove from favorites
                                                favoritesNotifier.state = {
                                                  ...favorites
                                                }..remove(job.id);
                                              } else {
                                                // Add to favorites
                                                favoritesNotifier.state = {
                                                  ...favorites,
                                                  job.id
                                                };
                                              }
                                            },
                                            child: Icon(
                                              isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorite
                                                  ? Colors.red
                                                  : Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Company Overview',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            // Company description
                            Text(
                              TextUtils.cleanHtmlText(job.companyDescription ??
                                  "${job.company}'s purpose is to innovate and deliver exceptional services to its customers."),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),

                            // Location and date if available
                            if (job.location != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    job.location!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (job.publishedDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatPublished(
                                        job.publishedDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (job.deadlineDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer,
                                      size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatDeadline(
                                        job.deadlineDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),
                            // Job Description heading
                            const Text(
                              'Job Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              TextUtils.cleanHtmlText(
                                  job.fullDescription ?? job.description),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 16),
                            // Key responsibilities
                            // const Text(
                            //   'Key responsibilities include:',
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            const SizedBox(height: 8),

                            // Responsibilities list
                            // _buildResponsibilitiesList(),

                            const SizedBox(height: 8),
                            // View counter
                            // Row(
                            //   children: [
                            //     const Icon(Icons.visibility,
                            //         size: 16, color: Colors.purple),
                            //     const SizedBox(width: 4),
                            //     Text(
                            //       'viewed ${job.views} times',
                            //       style: const TextStyle(
                            //         fontSize: 14,
                            //         color: Colors.purple,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Share button
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => _shareJob(job),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.pink,
                          side: const BorderSide(color: Colors.pink),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Share this job'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Apply button - simplified to just navigate
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await apiService.applyForJob(jobId);

                          if (context.mounted) {
                            await showResultDialog(
                              context: context,
                              message: result['message'] ?? 'Unknown response',
                              isSuccess: result['success'] ?? false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA60A7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply for this job'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



//**codes to be activated when we add the application with the cv */

//   Widget _buildResponsibilitiesList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 1. Leadership and Strategy
//         const Text(
//           '1. Leadership and Strategy',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         _buildBulletPoint(
//             'Manage Operations: Oversee day-to-day sales agents and operational staff'),
//         _buildBulletPoint('to meet organizational goals.'),

//         const SizedBox(height: 8),
//         // 2. Business Development
//         const Text(
//           '2. Business Development',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         _buildBulletPoint('Market Expansion: Identify and seize opportunities'),
//         _buildBulletPoint(
//             'Partnerships: Build relationships with key stakeholders and potential partners'),
//         _buildBulletPoint('Brand Promotion: Promote the brand'),

//         const SizedBox(height: 8),
//         // 3. Reporting and Performance
//         const Text(
//           '3. Reporting and Performance',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   } *** this will be the curl bracket to close the whole file ***

//   Widget _buildBulletPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16.0, top: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }


// Future<void> _navigateToApplicationForm(
//     BuildContext context, String jobId) async {
//   // Simply navigate to the application form screen with the job ID
//   if (context.mounted) {
//     context.push('/apply/$jobId/form');
//   }
// }
