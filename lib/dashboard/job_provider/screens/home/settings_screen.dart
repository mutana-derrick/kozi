import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/dashboard/job_provider/providers/providers.dart';
import 'package:kozi/dashboard/job_provider/widgets/reset_passsword_modal.dart';
import 'package:kozi/services/api_service.dart';
import 'package:kozi/shared/get_in_touch_screen.dart';
import 'package:kozi/shared/logout_dialog.dart';
import 'package:kozi/shared/policy_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(providerProfileProvider);

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
                            child: profileAsync.when(
                              data: (profile) {
                                final fullName =
                                    profile['full_name'] ?? 'Unknown';
                                final imageFile = profile['image'];
                                final imageUrl = (imageFile != null &&
                                        imageFile.isNotEmpty)
                                    ? '${ApiService.baseUrl}/provider/uploads/profile/$imageFile'
                                    : null;

                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: imageUrl != null
                                              ? Image.network(
                                                  imageUrl,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      _fallbackImage(),
                                                )
                                              : _fallbackImage(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'You are hiring through Kozi. Thank you for empowering talents!',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF666666),
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.push('/profile');
                                        ref
                                            .read(selectedNavIndexProvider
                                                .notifier)
                                            .state = 3;
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFEE5A9E),
                                        minimumSize:
                                            const Size(double.infinity, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                );
                              },
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (err, _) => Row(
                                children: [
                                  _fallbackImage(),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text('Could not load profile info.',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
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

                          _buildSettingsOption(
                            icon: Icons.lock,
                            iconColor: Colors.white,
                            backgroundColor: const Color(0xFFE74C3C),
                            title: 'Change Password',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) =>
                                    const ResetPasswordModal(),
                              );
                            },
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
                            icon: Icons.message,
                            iconColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 168, 206, 231),
                            title: 'Get in touch',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GetInTouchScreen(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    CustomLogoutDialog.show(context);
  }

  Widget _fallbackImage() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFF4CE5B1),
      child: const Icon(Icons.person, color: Colors.white, size: 40),
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
