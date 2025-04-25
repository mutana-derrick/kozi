// lib/authentication/job_seeker/providers/category_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';

// Provider for category types
final categoryTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final categoryTypesWithCategories = await apiService.getCategories();
    return categoryTypesWithCategories;
  } catch (e) {
    print('Error fetching category types: $e');
    return [];
  }
});

// Provider for the selected category type
final selectedCategoryTypeProvider = StateProvider<String?>((ref) => null);

// Provider for categories filtered by the selected type
final filteredCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final selectedTypeId = ref.watch(selectedCategoryTypeProvider);
  final categoryTypesAsync = ref.watch(categoryTypesProvider);
  
  return categoryTypesAsync.when(
    data: (categoryTypes) {
      if (selectedTypeId == null) return [];
      
      for (final typeData in categoryTypes) {
        if (typeData['type_id'].toString() == selectedTypeId) {
          return List<Map<String, dynamic>>.from(typeData['categories'] ?? []);
        }
      }
      return [];
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

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

// Helper function to get all category type names
List<String> getAllCategoryTypeNames(List<Map<String, dynamic>> categoriesData) {
  final List<String> names = [];
  
  for (final typeData in categoriesData) {
    if (typeData['type_name'] != null) {
      names.add(typeData['type_name']);
    }
  }
  
  return names;
}

// Helper function to get category type ID by name
String? getCategoryTypeIdByName(List<Map<String, dynamic>> categoriesData, String typeName) {
  for (final typeData in categoriesData) {
    if (typeData['type_name'] == typeName) {
      return typeData['type_id'].toString();
    }
  }
  return null;
}

// Helper function to get all category names
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

// Helper function to get category names by type ID
List<String> getCategoryNamesByTypeId(List<Map<String, dynamic>> categoriesData, String typeId) {
  final List<String> names = [];
  
  for (final typeData in categoriesData) {
    if (typeData['type_id'].toString() == typeId) {
      final List<Map<String, dynamic>> categoryList = 
          List<Map<String, dynamic>>.from(typeData['categories'] ?? []);
          
      for (final category in categoryList) {
        if (category['name'] != null) {
          names.add(category['name']);
        }
      }
      break;
    }
  }
  
  return names;
}