import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/services/api_service.dart';
import '../models/worker.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../providers/providers.dart';
import '../screens/home/worker_details_screen.dart'; // Added import for WorkerDetailScreen

final workersListProvider = FutureProvider<List<WorkerListItem>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.fetchWorkers();
    return response.map((workerJson) {
      return WorkerListItem(
        id: workerJson['users_id']?.toString() ??
            workerJson['id']
                .toString(), // Updated to use users_id like in WorkerRecommendations
        name: workerJson['full_name'] ?? workerJson['name'] ?? 'Unknown Worker',
        specialty: workerJson['category'] ?? 'Unspecified',
        imageUrl: workerJson['image'] != null &&
                workerJson['image'].toString().trim().isNotEmpty
            ? '${ApiService.baseUrl}/uploads/profile/${workerJson['image']}'
            : '', // Empty string will trigger fallback image
        rating: (workerJson['rating'] as num?)?.toDouble() ?? 0.0,
        isFavorite: false,
        categories: workerJson['categories'] is List
            ? List<String>.from(workerJson['categories'])
            : ['Unspecified'],
        isPartTime: workerJson['is_part_time'] ?? false,
        experience: workerJson['experience_level'] ?? 'Beginner',
        views: workerJson['views'] ?? 4,
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

  // Navigate to worker details screen
  void _navigateToWorkerDetails(String workerId) {
    // Debug print worker ID before navigation
    print('Navigating to worker details with ID: $workerId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkerDetailScreen(workerId: workerId),
      ),
    );
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
    return GestureDetector(
      onTap: () => _navigateToWorkerDetails(worker.id),
      child: Container(
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
                child: _buildWorkerImage(worker.imageUrl, 80, 80),
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
      ),
    );
  }

  // Enhanced worker image method with error handling
  Widget _buildWorkerImage(String imageUrl, double width, double height) {
    // If the image URL is empty or invalid, return fallback immediately
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _placeholderImage(width, height);
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
        return _placeholderImage(width, height);
      },
    );
  }

  Widget _placeholderImage([double width = 80, double height = 80]) {
    return Container(
      width: width,
      height: height,
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
