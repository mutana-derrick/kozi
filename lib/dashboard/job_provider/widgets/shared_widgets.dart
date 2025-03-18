// widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import '../screens/home/all_categories_screen.dart'; 

class SharedWidgets {
  // Helper widget for section headers
  static Widget buildSectionHeader(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            if (title == 'Categories') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllCategoriesScreen(),
                ),
              );
            }
          },
          child: const Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }
}