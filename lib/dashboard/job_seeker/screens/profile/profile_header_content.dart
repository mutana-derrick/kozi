import 'package:flutter/material.dart';
import 'package:kozi/authentication/job_seeker/widgets/profile_image_section.dart';
// import 'package:kozi/dashboard/job_seeker/widgets/profile_image_section.dart';

class ProfileHeaderContent extends StatelessWidget {
  const ProfileHeaderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}