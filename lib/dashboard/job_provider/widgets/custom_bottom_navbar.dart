import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(selectedNavIndexProvider.notifier).state = index;

        // Navigate using GoRouter based on selected index
        switch (index) {
          case 0:
            // Home
            context.go('/providerdashboardscreen');
            break;
          case 1:
            // Workers
            context.go('/workerslistcreen');
            break;
          case 2:
            // Support
            context.go('/support');
            break;
          case 3:
            // Profile
            context.go('/profile');
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
          icon: FaIcon(FontAwesomeIcons.users),
          label: 'Workers',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.headset),
          label: 'Support',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.user),
          label: 'Profile',
        ),
      ],
    );
  }
}