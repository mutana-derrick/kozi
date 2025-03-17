// providers/providers.dart
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/worker.dart';
import '../models/service_category.dart';

// Provider for workers list
final workersProvider = Provider<List<Worker>>((ref) {
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

// Provider for categories
final categoriesProvider = Provider<List<ServiceCategory>>((ref) {
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
});

// Stats data provider
final statsProvider = Provider<Map<String, int>>((ref) {
  return {
    'workers': 325,
    'employers': 81,
    'companies': 12,
  };
});

// Current user name provider
final userNameProvider = Provider<String>((ref) {
  return 'Allen';
});

// Selected bottom nav index provider
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);