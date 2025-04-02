import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/service_category.dart';
import '../providers/providers.dart';
import 'shared_widgets.dart';

// widgets/categories_section.dart
class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Tablet breakpoint

    return Column(
      children: [
        SharedWidgets.buildSectionHeader('Categories', context),
        const SizedBox(height: 15),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final cardWidth =
                  isLargeScreen ? 120.0 : 80.0; // Responsive width
              return _buildCategoryCard(category, cardWidth: cardWidth);
            },
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
