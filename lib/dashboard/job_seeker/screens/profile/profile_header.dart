import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_header.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final hasProfileImage = profileState.profileImagePath.isNotEmpty;

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
                    _buildProfileImage(context, ref, hasProfileImage, profileState.profileImagePath),
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

  Widget _buildProfileImage(BuildContext context, WidgetRef ref, bool hasProfileImage, String imagePath) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipOval(
            child: hasProfileImage
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        GestureDetector(
          onTap: () => _pickImage(context, ref),
          child: Container(
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
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    try {
      // Simulate picking image - in a real app, use ImagePicker
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image'),
          content: const Text('Choose an image source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(profileProvider.notifier).updateProfileImagePath('/path/to/selected_image.jpg');
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(profileProvider.notifier).updateProfileImagePath('/path/to/camera_image.jpg');
              },
              child: const Text('Camera'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}