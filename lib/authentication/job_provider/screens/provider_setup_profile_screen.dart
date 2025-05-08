import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_provider/providers/auth_provider.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_form_sections/address_form_section.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_form_sections/personal_info_form_section.dart';
import 'package:kozi/authentication/job_provider/providers/profile_provider.dart';
import 'package:kozi/authentication/job_provider/widgets/profile_image_section.dart';
import 'package:kozi/authentication/job_provider/widgets/progress_bar.dart';
import 'package:kozi/shared/get_in_touch_screen.dart';

class ProviderSetupProfileScreen extends ConsumerStatefulWidget {
  const ProviderSetupProfileScreen({super.key});

  @override
  ConsumerState<ProviderSetupProfileScreen> createState() => _ProviderSetupProfileScreenState();
}

class _ProviderSetupProfileScreenState extends ConsumerState<ProviderSetupProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
  }

  Future<void> _loadProviderProfile() async {
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

      final result = await apiService.getProviderProfile(userId);

      if (result['success'] && result['data'] != null) {
        final userData = result['data'];

        // Update profile provider with fetched data
        final profileNotifier = ref.read(profileProvider.notifier);
        profileNotifier.updateFirstName(userData['first_name'] ?? '');
        profileNotifier.updateLastName(userData['last_name'] ?? '');
        profileNotifier.updateGender(userData['gender'] ?? '');
        profileNotifier.updateTelephone(userData['telephone'] ?? '');
        // Date of birth is no longer needed but we'll keep it for backward compatibility
        profileNotifier.updateDateOfBirth(userData['date_of_birth'] ?? 'DD/MM/YYYY');
        // Update country field if available in the API response
        profileNotifier.updateCountry(userData['country'] ?? '');
        profileNotifier.updateProvince(userData['province'] ?? '');
        profileNotifier.updateDistrict(userData['district'] ?? '');
        profileNotifier.updateSector(userData['sector'] ?? '');
        profileNotifier.updateCell(userData['cell'] ?? '');
        profileNotifier.updateVillage(userData['village'] ?? '');
        profileNotifier.updateDescription(userData['description'] ?? '');

        // If the user has already completed their profile, we can start at a different step
        if (userData['province'] != null && userData['province'].toString().isNotEmpty) {
          profileNotifier.goToStep(1); // Go to address page if personal info is filled
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEA60A7),
          elevation: 0,
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
    
    return _ProfileScreenContent(errorMessage: _errorMessage);
  }
}

class _ProfileScreenContent extends ConsumerWidget {
  final String? errorMessage;
  
  const _ProfileScreenContent({this.errorMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
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
      body: Stack(
        children: [
          // Pink curved header background
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
                  ProfileImageSection(),
                ],
              ),
            ),
          ),

          // Error message if any
          if (errorMessage != null)
            Positioned(
              top: 180,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ),

          // Scrollable content that starts below the fixed header
          Positioned(
            top: headerHeight + (errorMessage != null ? 60 : 0),
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
      default:
        return const PersonalInfoFormSection();
    }
  }
}