import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kozi/dashboard/job_provider/models/service_category.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/screens/home/worker_details_screen.dart';
// import 'package:kozi/dashboard/job_provider/providers/providers.dart';

class CategoryWorkersScreen extends ConsumerWidget {
  final ServiceCategory category;

  const CategoryWorkersScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get all workers
    // final allWorkers = ref.watch(workersProvider);

    // For demo, we'll create mock data for babysitters
    // In a real app, you would filter workers by category
    final List<Worker> categoryWorkers = [
      Worker(
        id: '1',
        name: 'Kaneza Andrew',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker1.png',
        rating: 4.5,
      ),
      Worker(
        id: '2',
        name: 'Muyor Alexia',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker2.png',
        rating: 5.0,
      ),
      Worker(
        id: '3',
        name: 'Gahima Dorian',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker3.png',
        rating: 4.8,
      ),
      Worker(
        id: '4',
        name: 'Truluck Nik',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker4.png',
        rating: 4.2,
      ),
      Worker(
        id: '5',
        name: 'Muhoracyeye',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker5.png',
        rating: 4.7,
      ),
      Worker(
        id: '6',
        name: 'Truluck Nik',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker4.png',
        rating: 5.0,
      ),
      Worker(
        id: '7',
        name: 'Edward Ndekwe',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker3.png',
        rating: 4.3,
      ),
      Worker(
        id: '8',
        name: 'Thierry Alain',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker6.png',
        rating: 4.6,
      ),
      Worker(
        id: '9',
        name: 'Muneza Derrick',
        specialty: 'Mover Specialist',
        imageUrl: 'assets/worker3.png',
        rating: 4.9,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Popular ${category.name}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workers count banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.pink[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '15,000+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Workers found matching ${category.name}.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View sample Worker profiles below, or create a FREE Get Workers account to access and review real Worker profiles.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Popular Workers section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular ${category.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
            ),

            // Grid of workers
            GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 16,
              ),
              itemCount: categoryWorkers.length,
              itemBuilder: (context, index) {
                final worker = categoryWorkers[index];
                return _buildWorkerCard(context, worker);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Worker worker) {
    return GestureDetector(
      onTap: () {
        // Navigate to worker details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerDetailScreen(worker: worker),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Worker image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                worker.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Worker name
          Text(
            worker.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Worker specialty
          Text(
            worker.specialty,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),

          // Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < worker.rating.floor()
                    ? Icons.star
                    : (index < worker.rating
                        ? Icons.star_half
                        : Icons.star_border),
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
