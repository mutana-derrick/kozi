import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/screens/workers_list_screen.dart';
import '../screens/home/all_categories_screen.dart';
import '../providers/providers.dart';

class SharedWidgets {
  // Helper widget for section headers
  static Widget buildSectionHeader(String title, BuildContext context) {
    return Consumer(builder: (context, ref, child) {
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
              if (title == 'Worker Recommendations') {
                // Update the bottom navigation bar index to Workers (1)
                ref.read(selectedNavIndexProvider.notifier).state = 1;

                // Navigate to WorkersListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkersListScreen(),
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
    });
  }
}
