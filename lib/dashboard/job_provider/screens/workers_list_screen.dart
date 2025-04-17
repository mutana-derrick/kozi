import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/worker.dart';
import '../widgets/custom_bottom_navbar.dart';

class WorkersListScreen extends ConsumerStatefulWidget {
  const WorkersListScreen({super.key});

  @override
  ConsumerState<WorkersListScreen> createState() => _WorkersListScreenState();
}

class _WorkersListScreenState extends ConsumerState<WorkersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedPartTime = 'All';
  String _selectedExperience = 'All';

  // Track which filter is expanded
  String? _expandedFilter;

  // Temporary static data
  final List<WorkerListItem> _workers = [
    WorkerListItem(
      id: '1',
      name: 'Mwiza Anna',
      specialty: 'Specialist Mover',
      imageUrl: 'assets/worker1.png',
      rating: 2.8,
      views: 2821,
      isFavorite: true,
      categories: ['Moving', 'Logistics'],
      isPartTime: true,
      experience: 'Beginner',
    ),
    WorkerListItem(
      id: '2',
      name: 'Kaneza Andrew',
      specialty: 'Specialist Cleaner',
      imageUrl: 'assets/worker2.png',
      rating: 2.8,
      views: 2821,
      isFavorite: true,
      categories: ['Cleaning', 'Home Service'],
      isPartTime: false,
      experience: 'Intermediate',
    ),
    WorkerListItem(
      id: '3',
      name: 'Ether Wall',
      specialty: 'Specialist Chef',
      imageUrl: 'assets/worker3.png',
      rating: 2.8,
      views: 2821,
      isFavorite: true,
      categories: ['Chef', 'Cooking'],
      isPartTime: true,
      experience: 'Expert',
    ),
    WorkerListItem(
      id: '4',
      name: 'Byiringiro James',
      specialty: 'Specialist Mover',
      imageUrl: 'assets/worker4.png',
      rating: 2.8,
      views: 2821,
      isFavorite: false,
      categories: ['Moving', 'Logistics'],
      isPartTime: false,
      experience: 'Intermediate',
    ),
  ];

  List<WorkerListItem> get filteredWorkers {
    return _workers.where((worker) {
      // Search filter
      final searchMatch = _searchController.text.isEmpty ||
          worker.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          worker.specialty
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      // Category filter
      final categoryMatch = _selectedCategory == 'All' ||
          worker.categories.contains(_selectedCategory);

      // Part-time filter
      final partTimeMatch = _selectedPartTime == 'All' ||
          (_selectedPartTime == 'Part-time' && worker.isPartTime) ||
          (_selectedPartTime == 'Full-time' && !worker.isPartTime);

      // Experience filter
      final experienceMatch = _selectedExperience == 'All' ||
          worker.experience == _selectedExperience;

      return searchMatch && categoryMatch && partTimeMatch && experienceMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // App Bar
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

              // Search Bar
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

              // Filter chips in horizontal row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: _selectedCategory == 'All' &&
                            _selectedPartTime == 'All' &&
                            _selectedExperience == 'All',
                        onTap: () => setState(() {
                          _selectedCategory = 'All';
                          _selectedPartTime = 'All';
                          _selectedExperience = 'All';
                          _expandedFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButton(
                        label: 'Categories',
                        isActive: _selectedCategory != 'All',
                        isExpanded: _expandedFilter == 'category',
                        onTap: () {
                          setState(() {
                            _expandedFilter = _expandedFilter == 'category'
                                ? null
                                : 'category';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButton(
                        label: 'Part-time',
                        isActive: _selectedPartTime != 'All',
                        isExpanded: _expandedFilter == 'partTime',
                        onTap: () {
                          setState(() {
                            _expandedFilter = _expandedFilter == 'partTime'
                                ? null
                                : 'partTime';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButton(
                        label: 'Experience',
                        isActive: _selectedExperience != 'All',
                        isExpanded: _expandedFilter == 'experience',
                        onTap: () {
                          setState(() {
                            _expandedFilter = _expandedFilter == 'experience'
                                ? null
                                : 'experience';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Dropdown filter content
              if (_expandedFilter != null)
                Container(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildExpandedFilterContent(),
                ),

              // Workers list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];
                    return _buildWorkerCard(worker);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.pink[300]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.pink[100] : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.pink[300]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.pink[700] : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isActive ? Colors.pink[700] : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedFilterContent() {
    if (_expandedFilter == 'category') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          'Moving',
          'Cleaning',
          'Chef',
          'Logistics',
          'Home Service',
          'Cooking',
          'Moving',
          'Cleaning',
          'Chef'
        ].map((category) {
          return _buildFilterOptionChip(
            label: category,
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() {
                _selectedCategory =
                    _selectedCategory == category ? 'All' : category;
              });
            },
          );
        }).toList(),
      );
    } else if (_expandedFilter == 'partTime') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          'Part-time',
          'Full-time',
        ].map((option) {
          return _buildFilterOptionChip(
            label: option,
            isSelected: _selectedPartTime == option,
            onTap: () {
              setState(() {
                _selectedPartTime =
                    _selectedPartTime == option ? 'All' : option;
              });
            },
          );
        }).toList(),
      );
    } else if (_expandedFilter == 'experience') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          'Beginner',
          'Intermediate',
          'Expert',
        ].map((level) {
          return _buildFilterOptionChip(
            label: level,
            isSelected: _selectedExperience == level,
            onTap: () {
              setState(() {
                _selectedExperience =
                    _selectedExperience == level ? 'All' : level;
              });
            },
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFilterOptionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink[300] : Colors.pink[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.pink[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerCard(WorkerListItem worker) {
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
            // Worker image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                worker.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child:
                        const Icon(Icons.person, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Worker details
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
                          setState(() {
                            worker.isFavorite = !worker.isFavorite;
                          });
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
                    children: [
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
                      const SizedBox(width: 8),
                      Text(
                        '${worker.rating} (${worker.views} views)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extended worker model for list screen
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
