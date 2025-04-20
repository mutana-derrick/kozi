import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/screens/home/settings_screen.dart';
import 'package:kozi/dashboard/job_provider/widgets/custom_bottom_navbar.dart';
import 'package:kozi/authentication/job_provider/providers/profile_provider.dart';
import 'package:kozi/dashboard/job_provider/widgets/profile_form_sections/address_form_section.dart';
import 'package:kozi/dashboard/job_provider/widgets/profile_form_sections/personal_info_form_section.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_image_section.dart';
import 'package:kozi/authentication/job_provider/widgets/progress_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // Calculate header height (approximation)
    const headerHeight =
        220.0; // Pink background + profile image + some padding

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEE5A9E),
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
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
      body: Stack(
        children: [
          // Header Section with Gradient Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEE5A9E), Color(0xFFFF8FC8)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
          ),

          // Fixed header content
          Positioned(
            top: 0, // Adjusted from 70 since we moved to AppBar
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
                      'Update your profile to connect with workers more effectively.',
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
              child: Form(
                key: _formKey,
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

                    // Navigation buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: _buildNavigationButtons(profileState.currentStep),
                    ),

                    // Add some padding at the bottom for better scrolling experience
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildCurrentFormSection(int step) {
    switch (step) {
      case 0:
        return const PersonalInfoFormSection();
      case 1:
        return const AddressFormSection();
      // case 2:
      //   return const TechnicalFormSection();
      default:
        return const PersonalInfoFormSection();
    }
  }

  Widget _buildNavigationButtons(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (currentStep > 0)
          SizedBox(
            width: 150,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Color(0xFFEA60A7)),
              ),
              onPressed: () {
                ref.read(profileProvider.notifier).goToPreviousStep();
              },
              child: const Text(
                'Previous',
                style: TextStyle(
                  color: Color(0xFFEA60A7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        const SizedBox(width: 16),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA60A7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (currentStep < 1) {
                ref.read(profileProvider.notifier).goToNextStep();
              } else {
                // Save profile information
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Profile updated successfully!')),
                  );
                }
              }
            },
            child: Text(
              currentStep < 1 ? 'Next' : 'Update Profile',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
