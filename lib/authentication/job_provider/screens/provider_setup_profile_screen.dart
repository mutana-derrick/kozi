import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

// Define the profile state data class
class ProfileState {
  final String name;
  final String contactNumber;
  final String dateOfBirth;
  final String location;
  final bool isSubmitting;

  ProfileState({
    required this.name,
    required this.contactNumber,
    required this.dateOfBirth,
    required this.location,
    this.isSubmitting = false,
  });

  // Create a copy of the current state with some values modified
  ProfileState copyWith({
    String? name,
    String? contactNumber,
    String? dateOfBirth,
    String? location,
    bool? isSubmitting,
  }) {
    return ProfileState(
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// Create a notifier class to handle the state
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: "Mutesi Allen",
          contactNumber: "+250180000000",
          dateOfBirth: "DD MM YYYY",
          location: "Kacyiru-Kg 6470",
        ));

  void updateContactNumber(String number) {
    state = state.copyWith(contactNumber: number);
  }

  void updateDateOfBirth(String dob) {
    state = state.copyWith(dateOfBirth: dob);
  }

  // Method to submit profile data to backend
  Future<bool> submitProfile() async {
    // Set submitting state to true
    state = state.copyWith(isSubmitting: true);

    try {
      // TODO: Implement actual API call
      // For now, simulate a network request
      await Future.delayed(const Duration(seconds: 1));

      // Set submitting state to false
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // Set submitting state to false and handle error
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

// Create a provider for the ProfileNotifier
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

// The UI Screen
class ProviderSetupProfileScreen extends ConsumerWidget {
  const ProviderSetupProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends ConsumerStatefulWidget {
  const _ProfileScreenContent();

  @override
  ConsumerState<_ProfileScreenContent> createState() =>
      _ProfileScreenContentState();
}

class _ProfileScreenContentState extends ConsumerState<_ProfileScreenContent> {
  // Controllers for form fields
  late TextEditingController _contactController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with values from provider
    final profileState = ref.read(profileProvider);
    _contactController =
        TextEditingController(text: profileState.contactNumber);
    _dobController = TextEditingController(text: profileState.dateOfBirth);
  }

  @override
  void dispose() {
    _contactController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F5F5), // Light gray background matching the image
      appBar: AppBar(
        backgroundColor: const Color(0xFFEA60A7),
        elevation: 0,
        leading: null, // Removes the default leading icon
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              // TODO: Implement message functionality
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Pink curved header background
          Container(
            height: 160, // Adjust height as needed
            decoration: const BoxDecoration(
              color: Color(0xFFEA60A7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                // Pink header content
                Container(
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
                          'Update your profile to connect your doctor with better impression.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Profile image section
                      UpdatedProfileImageSection(),
                    ],
                  ),
                ),

                // Form section - updated to match the image
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Updated form fields to match the design
                      buildUpdatedFormField(
                        label: 'Name',
                        value: profileState.name,
                        editable: false,
                      ),
                      const SizedBox(height: 16),

                      buildUpdatedFormField(
                        label: 'Contact Number',
                        value: profileState.contactNumber,
                        editable: true,
                        onEdit: () {
                          // Show editing dialog or focus field
                        },
                      ),
                      const SizedBox(height: 16),

                      buildUpdatedFormField(
                        label: 'Date of birth',
                        value: profileState.dateOfBirth,
                        editable: true,
                        onEdit: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            final formattedDate =
                                "${picked.day.toString().padLeft(2, '0')} ${picked.month.toString().padLeft(2, '0')} ${picked.year}";
                            _dobController.text = formattedDate;
                            ref
                                .read(profileProvider.notifier)
                                .updateDateOfBirth(formattedDate);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      buildUpdatedFormField(
                        label: 'Location',
                        value: profileState.location,
                        editable: false,
                      ),
                      const SizedBox(height: 20),

// Submit button
Center(
  child: SizedBox(
    width: 200, // Fixed width to match design
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEA60A7),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // More rounded corners
        ),
        elevation: 0,
      ),
      onPressed: () => context.push('/providerdashboardscreen'),
      child: const Text(
        'Submit',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated form field to match the new design
  Widget buildUpdatedFormField({
    required String label,
    required String value,
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF00C853), // Bright green color for labels
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5C6BC0), // Indigo/purple text color
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (editable)
                  GestureDetector(
                    onTap: onEdit,
                    child: const FaIcon(
                      FontAwesomeIcons.penToSquare,
                      size: 18,
                      color: Color(0xFF5C6BC0), // Matching color to text
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Profile image section remains the same as before
class UpdatedProfileImageSection extends StatelessWidget {
  const UpdatedProfileImageSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/profile_placeholder.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const CircleAvatar(
                  backgroundColor: Color(0xFF00BCD4),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.camera,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
