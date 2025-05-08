import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';

class ProfileImageSection extends ConsumerWidget {
  const ProfileImageSection({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        ref.read(profileProvider.notifier).updateProfileImagePath(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final hasProfileImage = profileState.profileImagePath.isNotEmpty;

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
            child: hasProfileImage
                ? Image.file(
                    File(profileState.profileImagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        // Positioned(
        //   bottom: 0,
        //   right: 0,
        //   child: InkWell(
        //     onTap: () => _pickImage(context, ref),
        //     child: Container(
        //       padding: const EdgeInsets.all(2),
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         shape: BoxShape.circle,
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.black.withOpacity(0.1),
        //             blurRadius: 4,
        //             offset: const Offset(0, 2),
        //           ),
        //         ],
        //       ),
        //       child: Container(
        //         padding: const EdgeInsets.all(6),
        //         decoration: const BoxDecoration(
        //           color: Colors.black38,
        //           shape: BoxShape.circle,
        //         ),
        //         child: const FaIcon(
        //           FontAwesomeIcons.camera,
        //           color: Colors.white,
        //           size: 14,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
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
    );
  }
}
