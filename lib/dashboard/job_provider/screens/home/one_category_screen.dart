import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/models/service_category.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/screens/home/worker_details_screen.dart';

class CategoryWorkersScreen extends ConsumerStatefulWidget {
  final ServiceCategory category;

  const CategoryWorkersScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryWorkersScreen> createState() =>
      _CategoryWorkersScreenState();
}

class _CategoryWorkersScreenState extends ConsumerState<CategoryWorkersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Worker> filteredWorkers = [];

  // For demo, we'll create mock data for workers
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

  @override
  void initState() {
    super.initState();
    // Initialize filtered workers with all workers
    filteredWorkers = List.from(categoryWorkers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter workers based on search query
  void _filterWorkers() {
    if (_searchQuery.isEmpty) {
      filteredWorkers = List.from(categoryWorkers);
    } else {
      filteredWorkers = categoryWorkers.where((worker) {
        return worker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            worker.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Popular ${widget.category.name}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar - Always visible
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search workers',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filterWorkers();
                        });
                      },
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _filterWorkers();
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workers count banner
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.pink[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredWorkers.length}+',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Workers found matching ${widget.category.name}${_searchQuery.isNotEmpty ? ' and "${_searchQuery}"' : ''}.',
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
                          _searchQuery.isEmpty
                              ? 'Popular ${widget.category.name}'
                              : 'Search Results',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _filterWorkers();
                              });
                            },
                            child: const Text(
                              'Clear Search',
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // No results message
                  if (filteredWorkers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No workers found matching your search.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Grid of workers
                  if (filteredWorkers.isNotEmpty)
                    GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredWorkers.length,
                      itemBuilder: (context, index) {
                        final worker = filteredWorkers[index];
                        return _buildWorkerCard(context, worker);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
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
