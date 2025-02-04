import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kozi/admin/screens/agents_screen.dart';
import 'package:kozi/admin/screens/job_seekers_screen.dart';
import 'package:kozi/admin/screens/jobs_screen.dart';
import 'package:kozi/admin/screens/providers.dart';

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
final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, DashboardStats>((ref) {
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
  final List<Widget> _pages = [
    const DashboardHome(),
    const JobSeekersScreen(),
    const ProvidersScreen(),
    const JobsScreen(),
    const AgentsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(dashboardStatsProvider.notifier).fetchStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.white,
          indicatorColor: Colors.white,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.house),
              selectedIcon:
                  Icon(FontAwesomeIcons.house, color: Color(0xFFEA60A7)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userTie),
              selectedIcon:
                  Icon(FontAwesomeIcons.userTie, color: Color(0xFFEA60A7)),
              label: 'Job Seekers',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.buildingUser),
              selectedIcon:
                  Icon(FontAwesomeIcons.buildingUser, color: Color(0xFFEA60A7)),
              label: 'Providers',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.briefcase),
              selectedIcon:
                  Icon(FontAwesomeIcons.briefcase, color: Color(0xFFEA60A7)),
              label: 'Jobs',
            ),
            NavigationDestination(
              icon: Icon(FontAwesomeIcons.userGroup),
              selectedIcon:
                  Icon(FontAwesomeIcons.userGroup, color: Color(0xFFEA60A7)),
              label: 'Agents',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kozi Dashboard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: const Icon(FontAwesomeIcons.user, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, Admin',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                ),
              ],
            ),
          ),
        ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
