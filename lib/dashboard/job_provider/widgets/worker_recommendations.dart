import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/providers/providers.dart';
import 'package:kozi/dashboard/job_provider/screens/home/worker_details_screen.dart';
import 'package:kozi/services/api_service.dart';

import 'shared_widgets.dart';

// Provider for fetching workers
final workersFutureProvider = FutureProvider<List<Worker>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.fetchWorkers();
    // Add debug prints to verify the API response
    print("API Response: $response");
    if (response.isNotEmpty) {
      print("First worker data: ${response[0]}");
      print("First worker ID (users_id): ${response[0]['users_id']}");
    }

    return response
        .map((w) => Worker(
              // Ensure we're using users_id consistently
              id: w['users_id']?.toString() ?? w['id'].toString(),
              name: w['full_name'] ?? w['name'] ?? 'Unknown Worker',
              specialty: w['category'] ?? 'Unspecified',
              // Safer image URL construction with null check and empty string validation
              imageUrl:
                  w['image'] != null && w['image'].toString().trim().isNotEmpty
                      ? '${ApiService.baseUrl}/uploads/profile/${w['image']}'
                      : '',
              rating: 3.0, // Empty string will trigger fallback image
            ))
        .toList();
  } catch (e) {
    print('Error fetching workers: $e');
    return [];
  }
});

class WorkerRecommendations extends ConsumerWidget {
  const WorkerRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workersFutureProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Column(
      children: [
        SharedWidgets.buildSectionHeader('Worker Recommendations', context),
        const SizedBox(height: 15),
        workersAsync.when(
          data: (workers) {
            final limitedWorkers = workers.take(3).toList();
            return SizedBox(
              height: isLargeScreen ? 210 : 190,
              child: limitedWorkers.isEmpty
                  ? const Center(child: Text('No workers found'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: limitedWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = limitedWorkers[index];
                        final cardWidth = isLargeScreen ? 160.0 : 120.0;
                        return _buildWorkerCard(context, worker,
                            cardWidth: cardWidth);
                      },
                    ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: Colors.pink[300]),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading workers: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(BuildContext context, Worker worker,
      {required double cardWidth}) {
    return GestureDetector(
      onTap: () {
        // Debug print worker ID before navigation
        print('Navigating to worker details with ID: ${worker.id}');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerDetailScreen(workerId: worker.id),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildWorkerImage(worker.imageUrl, 120, 120),
            ),
            const SizedBox(height: 6),
            Text(
              worker.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              worker.specialty,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                5,
                (index) => Icon(
                  index < worker.rating.floor()
                      ? Icons.star
                      : index < worker.rating
                          ? Icons.star_half
                          : Icons.star_border,
                  color: Colors.amber,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to safely build worker image with better error handling
  Widget _buildWorkerImage(String imageUrl, double width, double height) {
    // If the image URL is empty or invalid, return fallback immediately
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _fallbackImage(width, height);
    }

    // For network images, use Image.network with error handling
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[300]!),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Log error but don't let it crash the app
        print('Error loading image: $error for URL: $imageUrl');
        return _fallbackImage(width, height);
      },
    );
  }

  Widget _fallbackImage([double width = 120, double height = 120]) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: FaIcon(FontAwesomeIcons.user, color: Colors.grey, size: 40),
      ),
    );
  }
}
