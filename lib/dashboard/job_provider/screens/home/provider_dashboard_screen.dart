// main_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kozi/dashboard/job_provider/screens/home/settings_screen.dart';
import 'package:kozi/dashboard/job_provider/widgets/settings_icon.dart';
// import '../models/worker.dart';
// import '../models/service_category.dart';
import '../../providers/providers.dart';
import '../../widgets/categories_section.dart';
import '../../widgets/worker_recommendations.dart';
import '../../widgets/custom_bottom_navbar.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider);
    final userName = ref.watch(userNameProvider);

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
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SettingsIconWidget(
                      iconColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Hello, $userName Need a worker today?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats cards
                        SizedBox(
                          height: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  count: stats['workers'] ?? 0,
                                  label: 'Workers',
                                  color: Colors.pink[100]!,
                                  iconData: FontAwesomeIcons.users,
                                ),
                                _buildStatCard(
                                  count: stats['employers'] ?? 0,
                                  label: 'Employers',
                                  color: Colors.pink[100]!,
                                  iconData: FontAwesomeIcons.userTie,
                                ),
                                _buildStatCard(
                                  count: stats['companies'] ?? 0,
                                  label: 'Companies',
                                  color: Colors.pink[100]!,
                                  iconData: FontAwesomeIcons.building,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Categories section
                        const CategoriesSection(),

                        const SizedBox(height: 25),

                        // Worker recommendations section
                        const WorkerRecommendations(),

                        const SizedBox(height: 25),

                        // Advertisement placeholder
                        Container(
                          width: double.infinity,
                          height: 60,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: const Center(
                            child: Text("Advertisement Placeholder"),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Request section
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "You don't get your category?",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Please you can send your request by tells worker you need.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Request An Estimate'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // Helper widget for stats cards
  Widget _buildStatCard({
    required int count,
    required String label,
    required Color color,
    required IconData iconData,
  }) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  iconData,
                  size: 14,
                  color: Colors.pink[400],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$count',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.pink[300],
            ),
          ),
        ],
      ),
    );
  }
}
