// lib/authentication/job_seeker/providers/category_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';


// Provider for categories
final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCategories();
});

// Helper function to get category ID by name
String getCategoryIdByName(List<Map<String, dynamic>> categories, String categoryName) {
  for (final typeData in categories) {
    final List<Map<String, dynamic>> categoryList = 
        List<Map<String, dynamic>>.from(typeData['categories'] ?? []);
        
    for (final category in categoryList) {
      if (category['name'] == categoryName) {
        return category['id'].toString();
      }
    }
  }
  return '1'; // Default value if not found
}

// Helper function to get category names as a flat list
List<String> getAllCategoryNames(List<Map<String, dynamic>> categoriesData) {
  final List<String> names = [];
  
  for (final typeData in categoriesData) {
    final List<Map<String, dynamic>> categoryList = 
        List<Map<String, dynamic>>.from(typeData['categories'] ?? []);
        
    for (final category in categoryList) {
      if (category['name'] != null) {
        names.add(category['name']);
      }
    }
  }
  
  return names;
}