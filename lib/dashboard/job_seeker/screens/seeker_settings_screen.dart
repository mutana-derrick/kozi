// lib/dashboard/job_seeker/screens/seeker_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/dashboard/job_seeker/widgets/reset_passsword_modal.dart';
import 'package:kozi/shared/get_in_touch_screen.dart';
import 'package:kozi/shared/logout_dialog.dart';
import 'package:kozi/shared/policy_screen.dart';

import '../widgets/custom_bottom_navbar.dart';

// Provider for user profile data in settings
final settingsProfileProvider =
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
    print('Error fetching profile for settings: $e');
    return null;
  }
});

class SeekerSettingsScreen extends ConsumerWidget {
  const SeekerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the profile provider to get user data
    final profileAsync = ref.watch(settingsProfileProvider);

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
                  child: SingleChildScrollView(
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

                          // Profile card (dynamic based on API data)
                          profileAsync.when(
                            data: (profileData) =>
                                _buildProfileCard(context, ref, profileData),
                            loading: () => _buildProfileCardSkeleton(),
                            error: (_, __) =>
                                _buildProfileErrorCard(context, ref),
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
                            onTap: () => _showChangePasswordModal(context),
                          ),
                          _buildSettingsOption(
                            icon: Icons.notifications,
                            iconColor: Colors.white,
                            backgroundColor: const Color(0xFF2ECC71),
                            title: 'Notifications',
                            onTap: () => _showNotImplementedSnackBar(
                                context, 'Notifications'),
                          ),
                          _buildSettingsOption(
                            icon: Icons.privacy_tip,
                            iconColor: Colors.white,
                            backgroundColor: const Color(0xFF3498DB),
                            title: 'Privacy Policy',
                            onTap: () => _navigateToPrivacyPolicy(context),
                          ),
                          _buildSettingsOption(
                            icon: Icons.message,
                            iconColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 168, 206, 231),
                            title: 'Get in touch',
                            onTap: () => _navigateToGetInTouch(context),
                          ),
                          _buildSettingsOption(
                            icon: Icons.info,
                            iconColor: Colors.white,
                            backgroundColor: const Color(0xFFE67E22),
                            title: 'About us',
                            onTap: () => _showNotImplementedSnackBar(
                                context, 'About us'),
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // Profile card with actual user data
  Widget _buildProfileCard(
      BuildContext context, WidgetRef ref, Map<String, dynamic>? profileData) {
    // Fallback to placeholder if profile data is null
    if (profileData == null) {
      return _buildProfileCardSkeleton();
    }

    final name =
        "${profileData['first_name'] ?? ''} ${profileData['last_name'] ?? ''}";
    final bio = profileData['bio'] ?? 'No bio provided';
    final imagePath = profileData['image'] ?? '';

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image - Show network image if available, or fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imagePath.isNotEmpty
                    ? Image.network(
                        'http://192.168.0.105:3000/uploads/$imagePath',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
              const SizedBox(width: 16),

              // Profile details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: const TextStyle(
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
            onPressed: () => _navigateToProfile(context, ref),
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
    );
  }

  // Profile card skeleton for loading state
  Widget _buildProfileCardSkeleton() {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),

              // Skeleton text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  // Profile error card when API fails
  Widget _buildProfileErrorCard(BuildContext context, WidgetRef ref) {
    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Default avatar
              _buildDefaultAvatar(),
              const SizedBox(width: 16),

              // Error message
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error loading profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Could not load your profile information. Please try again.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(settingsProfileProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE5A9E),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Default avatar widget
  Widget _buildDefaultAvatar() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFF4CE5B1),
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  // Setting option item
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

  // Handler for logout button
  void _handleLogout(BuildContext context, WidgetRef ref) {
    // Use the custom logout dialog with a callback for navigation
    CustomLogoutDialog.show(
      context,
      onLogoutComplete: (BuildContext ctx) {
        // This will be called after successful logout and dialog dismissal
        ctx.go('/home');
      },
    );
  }

  // Navigation to profile screen
  void _navigateToProfile(BuildContext context, WidgetRef ref) {
    context.push('/seekerprofile');
    ref.read(selectedNavIndex.notifier).state = 4;
  }

  // Show password change modal
  void _showChangePasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ResetPasswordModal(),
    );
  }

  // Navigation to privacy policy screen
  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // Navigation to get in touch screen
  void _navigateToGetInTouch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GetInTouchScreen(),
      ),
    );
  }

  // Show not implemented feature snackbar
  void _showNotImplementedSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature is coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
