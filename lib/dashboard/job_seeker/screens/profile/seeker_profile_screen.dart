import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/address_info_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/personal_info_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_form_sections/technical_info_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/profile_image_section.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_bottom_navbar.dart';

import 'package:kozi/shared/progress_bar.dart';
import 'package:kozi/shared/show_result_dialog.dart';

class SeekerProfileScreen extends ConsumerWidget {
  const SeekerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends ConsumerStatefulWidget {
  const _ProfileScreenContent();

  @override
  _ProfileScreenContentState createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends ConsumerState<_ProfileScreenContent> {
  final _formKey = GlobalKey<FormState>();

  // Keys for accessing section validation methods
  final GlobalKey<PersonalInfoSectionState> _personalInfoKey = GlobalKey();
  final GlobalKey<AddressInfoSectionState> _addressInfoKey = GlobalKey();
  final GlobalKey<TechnicalInfoSectionState> _technicalInfoKey = GlobalKey();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final apiService = ref.watch(apiServiceProvider);
      final userId = await apiService.getUserId();

      if (userId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await apiService.getUserProfile(userId);
      if (result['success'] && result['data'] != null) {
        final userData = result['data'];
        final profileNotifier = ref.read(profileProvider.notifier);

        // Map DB fields to provider
        profileNotifier.updateFirstName(userData['first_name'] ?? '');
        profileNotifier.updateLastName(userData['last_name'] ?? '');
        profileNotifier.updateFathersName(userData['fathers_name'] ?? '');
        profileNotifier.updateMothersName(userData['mothers_name'] ?? '');
        profileNotifier.updateTelephone(userData['telephone'] ?? '');
        profileNotifier.updateProvince(userData['province'] ?? '');
        profileNotifier.updateDistrict(userData['district'] ?? '');
        profileNotifier.updateSector(userData['sector'] ?? '');
        profileNotifier.updateCell(userData['cell'] ?? '');
        profileNotifier.updateVillage(userData['village'] ?? '');
        profileNotifier.updateDateOfBirth(userData['date_of_birth'] ?? '');
        profileNotifier.updateGender(userData['gender'] ?? '');
        profileNotifier.updateDisability(userData['disability'] ?? 'None');
        profileNotifier.updateExpectedSalary(userData['salary'] ?? '');
        profileNotifier.updateSkills(userData['bio'] ?? '');
        profileNotifier.updateCategory(userData['category_id'] ?? '');

        // Preload file paths for image, id and cv
        profileNotifier.updateProfileImagePath(userData['image'] ?? '');
        profileNotifier.updateNewIdCardPath(userData['id'] ?? '');
        profileNotifier.updateCvPath(userData['cv'] ?? '');

        // Navigate based on profile completeness
        if (userData['province'] != null &&
            userData['province'].toString().isNotEmpty) {
          profileNotifier.goToStep(1);
          if (userData['salary'] != null &&
              userData['salary'].toString().isNotEmpty) {
            profileNotifier.goToStep(2);
          }
        }
      }
    } catch (e) {
      // Handle error - could show a snackbar or error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // Show loading indicator while data is being loaded
    if (_isLoading) {
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
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFEA60A7),
          ),
        ),
      );
    }

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
            icon: const Icon(Icons.settings, size: 24, color: Colors.white),
            onPressed: () {
              Navigator.of(context).context.push('/seekersettings');
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Progress bar
                    ProfileSetupProgressBar(
                      currentStep: profileState.currentStep,
                      onStepTapped: (step) {
                        // Validate current section before allowing navigation
                        bool canNavigate = true;
                        if (step > profileState.currentStep) {
                          // Only validate if moving forward
                          canNavigate =
                              _validateCurrentSection(profileState.currentStep);
                        }

                        if (canNavigate) {
                          ref.read(profileProvider.notifier).goToStep(step);
                        } else {
                          // Show error message if validation fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill in all required fields before proceeding.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
        return PersonalInfoSection(key: _personalInfoKey);
      case 1:
        return AddressInfoSection(key: _addressInfoKey);
      case 2:
        return TechnicalInfoSection(key: _technicalInfoKey);
      default:
        return PersonalInfoSection(key: _personalInfoKey);
    }
  }

  // Method to validate current section
  bool _validateCurrentSection(int currentStep) {
    switch (currentStep) {
      case 0:
        return _personalInfoKey.currentState?.validateFields() ?? false;
      case 1:
        return _addressInfoKey.currentState?.validateFields() ?? false;
      case 2:
        return _technicalInfoKey.currentState?.validateFields() ?? false;
      default:
        return false;
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
            onPressed: () async {
              if (currentStep < 2) {
                // Validate current section before proceeding
                if (_validateCurrentSection(currentStep)) {
                  ref.read(profileProvider.notifier).goToNextStep();
                } else {
                  // Show error dialog if validation fails
                  await showResultDialog(
                    context: context,
                    message:
                        'Please fill in all required fields before proceeding.',
                    isSuccess: false,
                  );
                }
              } else {
                // Final step - validate and save profile
                if (_validateCurrentSection(currentStep)) {
                  try {
                    // Call the submit profile method from provider
                    await ref.read(profileProvider.notifier).submitProfile();

                    // Show success dialog
                    if (context.mounted) {
                      await showResultDialog(
                        context: context,
                        message: 'Profile updated successfully!',
                        isSuccess: true,
                      );
                    }
                  } catch (e) {
                    // Show error dialog if submission fails
                    if (context.mounted) {
                      await showResultDialog(
                        context: context,
                        message: 'Failed to update profile. Please try again.',
                        isSuccess: false,
                      );
                    }
                  }
                } else {
                  // Show error dialog if validation fails
                  await showResultDialog(
                    context: context,
                    message:
                        'Please fill in all required fields before saving.',
                    isSuccess: false,
                  );
                }
              }
            },
            child: Text(
              currentStep < 2 ? 'Next' : 'Update Profile',
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
