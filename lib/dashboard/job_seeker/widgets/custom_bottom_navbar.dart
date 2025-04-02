import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

final selectedNavIndex = StateProvider<int>((ref) => 0);

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndex);

    return BottomNavigationBar( 
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(selectedNavIndex.notifier).state = index;

        // Navigate using GoRouter based on selected index
        switch (index) {
          case 0:
            // Home
            context.go('/seekerdashboardscreen');
            break;
          case 1:
            // Jobs
            context.go('/jobs');
            break;
          case 2:
            // payment
            context.go('/payment');
            break;
          case 3:
            // Status
            context.go('/status');
            break;

          case 4:
            // Profile
            context.go('/seekerprofile');
            break;
        }
      },
      selectedItemColor: Colors.pink[300],
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.house),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.userGroup),
          label: 'Jobs',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.wallet), // Updated Payment Icon
          label: 'Payment',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.clipboardList),
          label: 'Status',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user),
          label: 'Profile',
        ),
      ],
    );
  }
}
