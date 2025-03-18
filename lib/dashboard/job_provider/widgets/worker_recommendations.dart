// widgets/worker_recommendations.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/worker.dart';
import '../providers/providers.dart';
import 'shared_widgets.dart';

class WorkerRecommendations extends ConsumerWidget {
  const WorkerRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workers = ref.watch(workersProvider);

    return Column(
      children: [
        SharedWidgets.buildSectionHeader('Worker Recommendations', context),
        const SizedBox(height: 15),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return _buildWorkerCard(worker);
            },
          ),
        ),
      ],
    );
  }

  // Helper widget for worker recommendation cards
  Widget _buildWorkerCard(Worker worker) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              worker.imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
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
            children: List.generate(5, (index) {
              return Icon(
                index < worker.rating.floor()
                    ? Icons.star
                    : index < worker.rating
                        ? Icons.star_half
                        : Icons.star_border,
                color: Colors.amber,
                size: 14,
              );
            }),
          ),
        ],
      ),
    );
  }
}
