import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Looking for a Job?',
      description:
          'Join thousands of workers finding jobs in cleaning, babysitting, driving, and more. Apply in just a few steps!',
      buttonText: 'Get Started',
      navigationRoute: '/seekerlogin',
    ),
    OnboardingItem(
      title: 'For Employers',
      description:
          'Hire professional and vetted workers for your home or business. Quick, secure, and hassle-free!',
      buttonText: 'Get Started',
      navigationRoute: '/providerlogin',
    ),
    OnboardingItem(
      title: 'Secure & Verified Platform',
      description:
          'We verify all job seekers and employers to ensure a trusted experience.',
      buttonText: 'Get Started',
      navigationRoute: '/home',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  item: _pages[index],
                  index: index,
                  onButtonPressed: () =>
                      context.go(_pages[index].navigationRoute),
                );
              },
            ),
            // Positioned at the bottom, taking into account the content layout
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(0xFFEA60A7)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String buttonText;
  final String navigationRoute;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.navigationRoute,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final int index;
  final VoidCallback onButtonPressed;

  const OnboardingPage({
    super.key,
    required this.item,
    required this.index,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section that fills the top half of the screen
        SizedBox(
          height: screenSize.height * 0.6, // 60% of screen height
          child: Image.asset(
            'assets/images/onboarding/${index + 1}.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Content area
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                // This Spacer ensures the button will be pushed to the bottom
                const Spacer(),
                // Button area with Skip option
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA60A7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          item.buttonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25), // Space for the indicator dots
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
