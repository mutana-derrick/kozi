import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/dashboard/job_seeker/models/job.dart';
import 'package:kozi/dashboard/job_seeker/screens/job_list/job_list_screen.dart';
import 'package:kozi/utils/text_utils.dart';
import 'dart:math' as math;

/// A reusable job card widget to be used across different screens.
class JobCardWidget extends ConsumerWidget {
  final Job job;
  final bool showApplyButton;
  final VoidCallback? onApplyPressed;
  final bool isLoading;

  const JobCardWidget({
    super.key,
    required this.job,
    this.showApplyButton = true,
    this.onApplyPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(job.id);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo
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
          // Job Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and favorite icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 0.9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      onPressed: () {
                        final favoritesNotifier =
                            ref.read(favoritesProvider.notifier);
                        final favorites = ref.read(favoritesProvider);

                        if (isFavorite) {
                          favoritesNotifier.state = {...favorites}
                            ..remove(job.id);
                        } else {
                          favoritesNotifier.state = {...favorites, job.id};
                        }
                      },
                    ),
                  ],
                ),

                // Corrected spacing between Title → Description
                const SizedBox(height: 0),

                // Description
                Text(
                  TextUtils.cleanHtmlText(job.description),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // Location if available
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

                // Deadline or rating/views
                Row(
                  children: [
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

                // Apply button
                if (showApplyButton) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : onApplyPressed ??
                                () {
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDeadlineDate(String dateString) {
    try {
      if (dateString.contains('T')) {
        final datePart = dateString.split('T')[0];
        final parts = datePart.split('-');
        if (parts.length == 3) {
          return '${parts[0]}-${parts[1]}-${parts[2]}';
        }
      }
      return dateString
          .replaceAll('T', ' ')
          .substring(0, math.min(10, dateString.length));
    } catch (e) {
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    }
  }
}

// Skeleton version of the job card for loading states
class JobCardSkeletonWidget extends StatelessWidget {
  const JobCardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 120,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
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
