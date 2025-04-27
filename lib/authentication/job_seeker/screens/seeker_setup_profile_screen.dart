import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/authentication/job_seeker/widgets/profile_form_sections/address_form_section.dart';
import 'package:kozi/authentication/job_seeker/widgets/profile_form_sections/personal_info_form_section.dart';
import 'package:kozi/authentication/job_seeker/widgets/profile_form_sections/technical_form_section.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/authentication/job_seeker/widgets/profile_image_section.dart';
import 'package:kozi/shared/progress_bar.dart';
import 'package:kozi/shared/get_in_touch_screen.dart';

// Provider to fetch user profile data
final userProfileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final userId = await apiService.getUserId();

  if (userId == null) {
    return null;
  }

  try {
    final result = await apiService.getUserProfile(userId);
    if (result['success']) {
      return result['data'];
    }
    return null;
  } catch (e) {
    print('Error fetching profile: $e');
    return null;
  }
});

class SeekerSetupProfileScreen extends ConsumerStatefulWidget {
  const SeekerSetupProfileScreen({super.key});

  @override
  ConsumerState<SeekerSetupProfileScreen> createState() =>
      _ProfileScreenContentState();
}

class _ProfileScreenContentState
    extends ConsumerState<SeekerSetupProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final userId = await apiService.getUserId();

      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      final result = await apiService.getUserProfile(userId);
      if (result['success'] && result['data'] != null) {
        final userData = result['data'];

        // Update profile provider with fetched data
        final profileNotifier = ref.read(profileProvider.notifier);
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
        profileNotifier
            .updateDateOfBirth(userData['date_of_birth'] ?? 'DD/MM/YYYY');
        profileNotifier.updateGender(userData['gender'] ?? '');
        profileNotifier.updateDisability(userData['disability'] ?? 'None');
        profileNotifier.updateExpectedSalary(userData['salary'] ?? '');
        profileNotifier.updateSkills(userData['bio'] ?? '');

        // If the user has already completed their profile, we can start at a different step
        if (userData['province'] != null &&
            userData['province'].toString().isNotEmpty) {
          profileNotifier
              .goToStep(1); // Go to address page if personal info is filled

          if (userData['salary'] != null &&
              userData['salary'].toString().isNotEmpty) {
            profileNotifier.goToStep(
                2); // Go to technical info if address info is also filled
          }
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // Calculate header height (approximation)
    const headerHeight = 220.0;

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
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
                        // Error message if any
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),

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
                          child: _buildCurrentFormSection(
                              profileState.currentStep),
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
        return const AddressInfoSection();
      case 2:
        return const TechnicalInfoSection();
      default:
        return const PersonalInfoFormSection();
    }
  }
}
