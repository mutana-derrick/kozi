import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Dashboard stats model
class DashboardStats {
  final int jobSeekers;
  final int jobProviders;
  final int availableJobs;
  final int agents;

  DashboardStats({
    required this.jobSeekers,
    required this.jobProviders,
    required this.availableJobs,
    required this.agents,
  });
}

// Dashboard provider
final dashboardStatsProvider = StateNotifierProvider<DashboardStatsNotifier, DashboardStats>((ref) {
  return DashboardStatsNotifier();
});

class DashboardStatsNotifier extends StateNotifier<DashboardStats> {
  DashboardStatsNotifier()
      : super(DashboardStats(
          jobSeekers: 0,
          jobProviders: 0,
          availableJobs: 0,
          agents: 0,
        ));

  // Add methods to update stats
  Future<void> fetchStats() async {
    // Implement API call here
    // For now, using dummy data
    state = DashboardStats(
      jobSeekers: 23,
      jobProviders: 12,
      availableJobs: 35,
      agents: 8,
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardStatsProvider.notifier).fetchStats());
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kozi Dashboard'),
        actions: [
          CircleAvatar(
            child: Icon(FontAwesomeIcons.user),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Admin',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatCard(
                  title: 'Job Seekers',
                  value: stats.jobSeekers,
                  icon: FontAwesomeIcons.userTie,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Job Providers',
                  value: stats.jobProviders,
                  icon: FontAwesomeIcons.buildingUser,
                  color: Colors.red,
                ),
                _StatCard(
                  title: 'Available Jobs',
                  value: stats.availableJobs,
                  icon: FontAwesomeIcons.briefcase,
                  color: Colors.amber,
                ),
                _StatCard(
                  title: 'Agents',
                  value: stats.agents,
                  icon: FontAwesomeIcons.userGroup,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // Implement navigation using GoRouter here
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.house),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userTie),
              label: 'Job Seekers',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.buildingUser),
              label: 'Providers',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.briefcase),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userGroup),
              label: 'Agents',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}