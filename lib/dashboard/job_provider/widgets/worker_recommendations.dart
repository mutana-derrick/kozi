// widgets/worker_recommendations.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/worker.dart';
import '../providers/providers.dart';
import 'shared_widgets.dart';

// widgets/worker_recommendations.dart
class WorkerRecommendations extends ConsumerWidget {
  const WorkerRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(workersProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Column(
      children: [
        SharedWidgets.buildSectionHeader('Worker Recommendations', context),
        const SizedBox(height: 15),
        SizedBox(
          // Increased height to accommodate potential text scaling
          height: isLargeScreen ? 210 : 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              final cardWidth = isLargeScreen ? 160.0 : 120.0;
              return _buildWorkerCard(worker, cardWidth: cardWidth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerCard(Worker worker, {required double cardWidth}) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
          mainAxisSize: MainAxisSize.min, // Add this line
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                worker.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(child: FaIcon(FontAwesomeIcons.user)),
                ),
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
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
              mainAxisSize: MainAxisSize.min, // Add this line
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
                      )),
            ),
          ]),
    );
  }
}
