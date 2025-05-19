import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/providers.dart';

final workersListProvider = FutureProvider<List<WorkerListItem>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.fetchWorkers();
    return response.map((workerJson) {
      return WorkerListItem(
        id: workerJson['id'].toString(),
        name: workerJson['full_name'] ?? workerJson['name'],
        specialty: workerJson['category'] ?? 'Unspecified',
        imageUrl: workerJson['image'] ?? 'assets/default_worker.png',
        rating: (workerJson['rating'] as num?)?.toDouble() ?? 0.0,
        isFavorite: false,
        categories: workerJson['categories'] is List
            ? List<String>.from(workerJson['categories'])
            : ['Unspecified'],
        isPartTime: workerJson['is_part_time'] ?? false,
        experience: workerJson['experience_level'] ?? 'Beginner',
        views: workerJson['views'] ?? 0,
      );
    }).toList();
  } catch (e) {
    print('Error fetching workers: $e');
    return [];
  }
});

class WorkersListScreen extends ConsumerStatefulWidget {
  const WorkersListScreen({super.key});

  @override
  ConsumerState<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends ConsumerState<WorkersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _workersPerPage = 5;

  List<WorkerListItem> _filterWorkers(List<WorkerListItem> workers) {
    return workers.where((worker) {
      final searchMatch = _searchController.text.isEmpty ||
          worker.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          worker.specialty
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return searchMatch;
    }).toList();
  }

  void _toggleFavorite(WorkerListItem worker) {
    setState(() {
      worker.isFavorite = !worker.isFavorite;
      final workersAsync = ref.read(workersListProvider);
      workersAsync.whenData((workers) {
        workers.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return 0;
        });
      });
      if (worker.isFavorite) {
        // ignore: unused_result
        ref.refresh(workersListProvider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(workersListProvider);
    // Get the available screen height to calculate minimum content height
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate minimum height (subtract app bar, search bar, padding and bottom nav)
    final minContentHeight = screenHeight - 200; // Adjust this value as needed

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [Color(0xFFF8BADC), Color.fromARGB(255, 250, 240, 245)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Workers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Expanded to fill remaining space
              Expanded(
                child: workersAsync.when(
                  data: (workers) {
                    final filteredWorkers = _filterWorkers(workers);
                    final startIndex = (_currentPage - 1) * _workersPerPage;
                    final endIndex = (_currentPage * _workersPerPage) >
                            filteredWorkers.length
                        ? filteredWorkers.length
                        : (_currentPage * _workersPerPage);

                    final pageWorkers =
                        filteredWorkers.sublist(startIndex, endIndex);

                    if (filteredWorkers.isEmpty) {
                      return Center(
                        child: Text(
                          'No workers found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }

                    return Container(
                      constraints: BoxConstraints(
                        minHeight: minContentHeight,
                      ),
                      child: Column(
                        children: [
                          // Workers list
                          Expanded(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: pageWorkers.length,
                              itemBuilder: (context, index) {
                                final worker = pageWorkers[index];
                                return _buildWorkerCard(worker);
                              },
                            ),
                          ),
                          // Pagination
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                (filteredWorkers.length / _workersPerPage)
                                    .ceil(),
                                (index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _currentPage = index + 1;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _currentPage == index + 1
                                            ? Colors.pink
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: _currentPage == index + 1
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.pink),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'Error loading workers: $error',
                      style: TextStyle(color: Colors.red),
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

  Widget _buildWorkerCard(WorkerListItem worker) {
    final isNetworkImage = worker.imageUrl.startsWith('http');
    final imageWidget = isNetworkImage
        ? Image.network(
            worker.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _placeholderImage();
            },
          )
        : Image.asset(
            worker.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _placeholderImage();
            },
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          worker.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: worker.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleFavorite(worker);
                        },
                      ),
                    ],
                  ),
                  Text(
                    worker.specialty,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < worker.rating.floor()
                            ? Icons.star
                            : index < worker.rating
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }
}

class WorkerListItem extends Worker {
  bool isFavorite;
  List<String> categories;
  bool isPartTime;
  String experience;
  int views;

  WorkerListItem({
    required super.id,
    required super.name,
    required super.specialty,
    required super.imageUrl,
    required super.rating,
    required this.isFavorite,
    required this.categories,
    required this.isPartTime,
    required this.experience,
    required this.views,
  });
}
