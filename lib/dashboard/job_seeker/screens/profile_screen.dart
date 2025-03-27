import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_seeker/wigets/custom_bottom_navbar.dart';
import 'package:kozi/dashboard/job_seeker/wigets/custom_header.dart';

class SeekerProfileScreen extends ConsumerWidget {
  const SeekerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              _buildPersonalInformation(userProfile, context),
              const SizedBox(height: 20),
              _buildUpdateButton(context),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFEA60A7),
          ),
          child: Column(
            children: [
              const CustomHeader(title: 'Profile'),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                width: double.infinity,
                color: const Color(0xFFEA60A7),
                child: Column(
                  children: [
                    const Text(
                      'Set up your profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update your profile to connect your Employer with better impression.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.teal,
                          child: ClipOval(
                            child: Image.network(
                              'https://example.com/profile.jpg',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Add the curved border separately at the bottom
        Container(
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFEA60A7),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformation(
      UserProfile userProfile, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Name',
            value: userProfile.name,
            canEdit: false,
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Contact Number',
            value: '+250180000000',
            canEdit: true,
            onEdit: () {
              // Handle edit
            },
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Date of birth',
            value: 'DD MM YYYY',
            canEdit: true,
            onEdit: () {
              // Handle edit
            },
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'Location',
            value: 'Kacyiru-Kg 6470',
            canEdit: false,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required bool canEdit,
    VoidCallback? onEdit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (canEdit)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(
                    Icons.edit,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: ElevatedButton(
        onPressed: () {
          // Handle update
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEA60A7),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: const Text(
          'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Updated UserProfile model to include more fields if needed
class UserProfile {
  final String name;
  final String imageUrl;
  final int age;
  final String location;
  final String specialization;
  final int rating;
  final String contactNumber;
  final String dateOfBirth;

  UserProfile({
    required this.name,
    required this.imageUrl,
    required this.age,
    required this.location,
    required this.specialization,
    required this.rating,
    this.contactNumber = '+250180000000',
    this.dateOfBirth = 'DD MM YYYY',
  });
}

// Updated provider
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Mutesi Allen',
    imageUrl: 'https://example.com/profile.jpg',
    age: 24,
    location: 'Kacyiru-Kg 6470',
    specialization: 'housekeeping and cleaning',
    rating: 4,
    contactNumber: '+250180000000',
    dateOfBirth: 'DD MM YYYY',
  );
});
