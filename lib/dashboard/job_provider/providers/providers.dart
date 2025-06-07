import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import '../models/worker.dart';
import '../models/service_category.dart';
import 'package:kozi/services/api_service.dart';

// ApiService Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Dio instance provider
final dioProvider = Provider<Dio>((ref) {
  return Dio(); // Create a Dio instance
});

// Current user name provider
final userNameProvider = Provider<String>((ref) {
  return 'Allen';
});

// Provider for fetching categories from API
final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    return await apiService.fetchCategories();
  } catch (e) {
    print('Error in categoriesProvider: $e');
    // Return fallback categories if API fails
    return [
      ServiceCategory(
        id: '1',
        name: 'Home Service',
        icon: FontAwesomeIcons.house,
      ),
      ServiceCategory(
        id: '2',
        name: 'Office Cleaning',
        icon: FontAwesomeIcons.broom,
      ),
      ServiceCategory(
        id: '3',
        name: 'Babysitting',
        icon: FontAwesomeIcons.baby,
      ),
      ServiceCategory(
        id: '4',
        name: 'Chefs Service',
        icon: FontAwesomeIcons.utensils,
      ),
    ];
  }
});

// Provider for fetching workers by category ID
final categoryWorkersProvider =
    FutureProvider.family<List<dynamic>, String>((ref, categoryId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    // Return the raw data from the API
    final workersData = await apiService.fetchWorkersByCategory(categoryId);
    return workersData;
  } catch (e) {
    print('Error fetching workers for category $categoryId: $e');
    // Return empty list as fallback
    return [];
  }
});

// Provider for converting API worker data to Worker objects
final processedWorkersProvider =
    Provider.family<List<Worker>, List<dynamic>>((ref, workersData) {
  if (workersData.isEmpty) {
    return ref.read(mockWorkersProvider);
  }

  // Convert the dynamic data to Worker objects
  try {
    return workersData
        .map<Worker>((worker) => Worker(
              id: worker['id']?.toString() ??
                  worker['users_id']?.toString() ??
                  '0',
              name: worker['name'] ?? worker['username'] ?? 'Unknown',
              specialty:
                  worker['category'] ?? worker['service_name'] ?? 'Specialist',
              imageUrl: worker['image_url'] ??
                  worker['profile_image'] ??
                  'assets/default_worker.png',
              rating: (worker['rating'] != null)
                  ? double.parse(worker['rating'].toString())
                  : (worker['average_rating'] != null)
                      ? double.parse(worker['average_rating'].toString())
                      : 0.0,
            ))
        .toList();
  } catch (e) {
    print('Error processing workers data: $e');
    return ref.read(mockWorkersProvider);
  }
});

// Mock workers provider (for fallback)
final mockWorkersProvider = Provider<List<Worker>>((ref) {
  return [
    Worker(
      id: '1',
      name: 'Kaneza Andrew',
      specialty: 'Cleaning Specialist',
      imageUrl: 'assets/worker1.png',
      rating: 3.0,
    ),
    Worker(
      id: '2',
      name: 'Mwiza Aline',
      specialty: 'Babysitter Specialist',
      imageUrl: 'assets/worker2.png',
      rating: 3.5,
    ),
    Worker(
      id: '3',
      name: 'Kabati',
      specialty: 'Chef Specialist',
      imageUrl: 'assets/worker3.png',
      rating: 2.0,
    ),
  ];
});

// Stats Provider
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    final workers = await apiService.getSeekersCount();
    final companies = await apiService.getCompanyProvidersCount(); // companies
    final individuals = await apiService
        .getIndividualProvidersCount(); // actually individual count

    return {
      'workers': workers,
      'companies': companies,
      'individuals': individuals,
    };
  } catch (e) {
    print('Error fetching stats: $e');
    return {
      'workers': 0,
      'companies': 0,
      'individuals': 0,
    };
  }
});

final providerProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  final userId = await apiService.getUserId(); // Already handles secure storage/email fallback
  if (userId == null) throw Exception('User ID not found');

  final response = await apiService.getProviderProfile(userId);
  if (response['success'] == true) {
    return response['data'];
  } else {
    throw Exception(response['message'] ?? 'Failed to load provider profile');
  }
});


// Selected bottom nav index provider
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);
