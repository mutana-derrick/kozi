import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/shared/logout_dialog.dart';
import 'package:kozi/shared/policy_screen.dart';

class SeekerSettingsScreen extends ConsumerWidget {
  const SeekerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEE5A9E), Color(0xFFFF8FC8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Settings and More',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F0F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Profile card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Profile image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/profile_picture.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        width: 80,
                                        height: 80,
                                        color: const Color(0xFF4CE5B1),
                                        child: const Icon(Icons.person,
                                            color: Colors.white, size: 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Profile details
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mutesi Allen',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'I am 24 years old, I Live in Kigali and Specialist in housekeeping and cleaning......',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF666666),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to edit profile
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEE5A9E),
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Account settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Settings options
                        _buildSettingsOption(
                          icon: Icons.lock,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFFE74C3C),
                          title: 'Change Password',
                          onTap: () {},
                        ),
                        _buildSettingsOption(
                          icon: Icons.notifications,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF2ECC71),
                          title: 'Notifications',
                          onTap: () {},
                        ),
                        _buildSettingsOption(
                          icon: Icons.privacy_tip,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFF3498DB),
                          title: 'Privacy Policy',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSettingsOption(
                          icon: Icons.info,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFFE67E22),
                          title: 'About us',
                          onTap: () {},
                        ),
                        _buildSettingsOption(
                          icon: Icons.logout,
                          iconColor: Colors.white,
                          backgroundColor: const Color(0xFFE74C3C),
                          title: 'Logout',
                          onTap: () => _handleLogout(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    CustomLogoutDialog.show(
      context,
      onConfirm: () {
        // Implement your logout logic here
        // For example:
        // ref.read(authProvider.notifier).logout();

        // Navigate to login screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
