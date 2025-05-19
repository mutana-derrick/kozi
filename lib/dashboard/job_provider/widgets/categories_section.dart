import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/service_category.dart';
import '../providers/providers.dart';
import 'shared_widgets.dart';

// New provider for dynamic categories
final categoriesFutureProvider =
    FutureProvider<List<ServiceCategory>>((ref) async {
  final apiService = ref.read(apiServiceProvider);

  try {
    // Fetch categories directly as ServiceCategory objects
    return await apiService.fetchCategories();
  } catch (e) {
    print('Error in categoriesFutureProvider: $e');
    return [];
  }
});

// Helper function to map category names to icons
IconData _mapIconToCategory(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'home service':
      return FontAwesomeIcons.house;
    case 'pool cleaners':
      return FontAwesomeIcons.broom;
    case 'baby sitters':
      return FontAwesomeIcons.baby;
    case 'chefs service':
      return FontAwesomeIcons.utensils;
    default:
      return FontAwesomeIcons.layerGroup;
  }
}

// widgets/categories_section.dart
class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Column(
      children: [
        SharedWidgets.buildSectionHeader('Categories', context),
        const SizedBox(height: 15),
        categoriesAsync.when(
          data: (categories) {
            // Limit to maximum 4 categories
            final limitedCategories = categories.take(4).toList();

            return SizedBox(
              height: 110,
              child: limitedCategories.isEmpty
                  ? const Center(child: Text('No categories found'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: limitedCategories.length,
                      itemBuilder: (context, index) {
                        final category = limitedCategories[index];
                        final cardWidth = isLargeScreen ? 120.0 : 80.0;
                        return _buildCategoryCard(category,
                            cardWidth: cardWidth);
                      },
                    ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: Colors.pink[300]),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading categories: $error'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(ServiceCategory category,
      {required double cardWidth}) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            width: 60, // Fixed icon size
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                category.icon,
                color: Colors.pink[300],
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
