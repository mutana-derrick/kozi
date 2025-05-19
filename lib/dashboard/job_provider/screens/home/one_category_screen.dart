import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/models/service_category.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/screens/home/worker_details_screen.dart';
import 'package:kozi/dashboard/job_provider/providers/providers.dart';
import 'package:kozi/services/api_service.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Convert API worker data to Worker model
  Worker _convertToWorkerModel(dynamic workerData) {
    return Worker(
      id: workerData['users_id'].toString(),
      name: workerData['full_name'] ??
          '${workerData['first_name']} ${workerData['last_name']}',
      specialty: widget.category.name,
      // Use a default image if image is not available
      imageUrl: workerData['image'] != null && workerData['image'].isNotEmpty
          ? 'uploads/profile/${workerData['image']}'
          : 'assets/default_profile.png',
      rating: 4.0, // Default rating since it's not available in the API
    );
  }

  // Filter workers based on search query
  List<Worker> _getFilteredWorkers(List<Worker> allWorkers) {
    if (_searchQuery.isEmpty) {
      return allWorkers;
    } else {
      return allWorkers.where((worker) {
        return worker.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            worker.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final workersAsync = ref.watch(categoryWorkersProvider(widget.category.id));

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
            child: workersAsync.when(
              data: (workersData) {
                // Convert API data to Worker models
                final List<Worker> workers = workersData.map<Worker>((worker) {
                  return _convertToWorkerModel(worker);
                }).toList();

                final filteredWorkers = _getFilteredWorkers(workers);

                return SingleChildScrollView(
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
                              'View Worker profiles below, or create a FREE Get Workers account to access and review real Worker profiles.',
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
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load workers',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .refresh(categoryWorkersProvider(widget.category.id)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
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
            builder: (context) => WorkerDetailScreen(workerId: worker.id),
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
              child: worker.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      worker.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.person,
                                size: 40, color: Colors.grey),
                          ),
                        );
                      },
                    )
                  : Image.network(
                      '${ApiService.baseUrl}/${worker.imageUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.person,
                                size: 40, color: Colors.grey),
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
