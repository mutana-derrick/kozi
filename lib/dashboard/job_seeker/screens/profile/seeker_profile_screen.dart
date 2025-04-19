import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/address_info_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/personal_info_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/technical_info_section.dart';
import 'package:kozi/dashboard/job_seeker/screens/profile/profile_header_content.dart';

import 'package:kozi/dashboard/job_seeker/widgets/custom_bottom_navbar.dart';

import 'package:kozi/shared/progress_bar.dart';

import 'package:kozi/shared/get_in_touch_screen.dart';

class SeekerProfileScreen extends ConsumerStatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  ConsumerState<SeekerProfileScreen> createState() =>
      _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends ConsumerState<SeekerProfileScreen> {
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileHeaderContent(),
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
        return const PersonalInfoSection();
      case 1:
        return const AddressInfoSection();
      case 2:
        return const TechnicalInfoSection();
      default:
        return const PersonalInfoSection();
    }
  }
}
