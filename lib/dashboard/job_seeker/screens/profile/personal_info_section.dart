import 'package:flutter/material.dart';
import 'package:kozi/dashboard/job_seeker/models/user_profile_model.dart';
import 'info_field.dart';

class PersonalInfoSection extends StatelessWidget {
  final UserProfile userProfile;

  const PersonalInfoSection({
    super.key,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
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
          InfoField(
            label: 'Name',
            value: userProfile.name,
            canEdit: false,
          ),
          const SizedBox(height: 16),
          InfoField(
            label: 'Contact Number',
            value: userProfile.contactNumber,
            canEdit: true,
            onEdit: () {
              // Handle edit contact number
            },
          ),
          const SizedBox(height: 16),
          InfoField(
            label: 'Date of birth',
            value: userProfile.dateOfBirth,
            canEdit: true,
            onEdit: () {
              // Handle edit date of birth
            },
          ),
          const SizedBox(height: 16),
          InfoField(
            label: 'Location',
            value: userProfile.location,
            canEdit: false,
          ),
        ],
      ),
    );
  }
}