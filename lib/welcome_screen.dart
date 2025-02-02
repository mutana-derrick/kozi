import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void _showUserSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
    ),
    builder: (context) {
      return SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 20,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        "Continue as",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isWide)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child:
                                    _buildOption(context, "Admin", "/login")),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildOption(
                                    context, "Job Seeker", "/login")),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildOption(
                                    context, "Job Provider", "/login")),
                            const SizedBox(width: 8),
                            Expanded(
                                child:
                                    _buildOption(context, "Agent", "/login")),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildOption(context, "Admin", "/login"),
                            _buildOption(context, "Job Seeker", "/login"),
                            _buildOption(context, "Job Provider", "/login"),
                            _buildOption(context, "Agent", "/login"),
                          ],
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildOption(BuildContext context, String title, String route) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.pop();
          context.push(route);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: const Color(0xFFEA60A7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        ),
      ),
    ),
  );
}

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Top text section
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(
                            fontSize: 18, // Reduced font size
                            fontWeight: FontWeight.w400, // Normal weight
                            color: Colors.black, // Black text color
                          ),
                        ),
                        TextSpan(
                          text: 'Kozi', // Bold and different color
                          style: TextStyle(
                            fontSize: 20, // Slightly larger for emphasis
                            fontWeight: FontWeight.bold,
                            color:
                                Color(0xFF0F1D45), // Dark blue for distinction
                          ),
                        ),
                        TextSpan(
                          text: ' Rwanda – where talent meets opportunity! ',
                          style: TextStyle(
                            fontSize: 18, // Same smaller size
                            fontWeight: FontWeight.w400,
                            color: Colors.black, // Black text color
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Logo/image section
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 450, // Matches the Figma width
                      maxHeight: 400, // Matches the Figma height
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width *
                          15, // Slightly responsive
                      height: MediaQuery.of(context).size.height * 0.9,
                      fit: BoxFit
                          .contain, // Adjusts the image to stay within bounds
                    ),
                  ),
                ),
              ),

              // Bottom button section
              // Bottom Button
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity, // Full-width button
                    child: ElevatedButton(
                      onPressed: () => _showUserSelectionSheet(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor:
                            const Color(0xFFEA60A7), // Pink background
                        foregroundColor: Colors.white, // White text
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        "Continue as",
                        style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
