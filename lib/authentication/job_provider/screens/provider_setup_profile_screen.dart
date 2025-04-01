import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_form_sections/address_form_section.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_form_sections/personal_info_form_section.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_form_sections/technical_form_section.dart';
import 'package:kozi/authentication/job_provider/providers/profile_provider.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_image_section.dart';
import 'package:kozi/authentication/job_provider/widgets/progress_bar.dart';
import 'package:kozi/shared/get_in_touch_screen.dart';

class ProviderSetupProfileScreen extends ConsumerWidget {
  const ProviderSetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends ConsumerWidget {
  const _ProfileScreenContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    // final screenHeight = MediaQuery.of(context).size.height;

    // Calculate header height (approximation)
    const headerHeight =
        220.0; // Pink background + profile image + some padding

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEA60A7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GetInTouchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Pink curved header background (fixed)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFFEA60A7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // Fixed header content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Column(
                children: [
                  Text(
                    'Set up your profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Update your profile to connect with better opportunities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Profile image section (also fixed)
                  ProfileImageSection(),
                ],
              ),
            ),
          ),

          // Scrollable content that starts below the fixed header
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Progress bar
                  ProfileSetupProgressBar(
                    currentStep: profileState.currentStep,
                    onStepTapped: (step) {
                      ref.read(profileProvider.notifier).goToStep(step);
                    },
                  ),

                  // Form sections - show based on current step
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildCurrentFormSection(profileState.currentStep),
                  ),

                  // Add some padding at the bottom for better scrolling experience
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFormSection(int step) {
    switch (step) {
      case 0:
        return const PersonalInfoFormSection();
      case 1:
        return const AddressFormSection();
      case 2:
        return const TechnicalFormSection();
      default:
        return const PersonalInfoFormSection();
    }
  }
}
