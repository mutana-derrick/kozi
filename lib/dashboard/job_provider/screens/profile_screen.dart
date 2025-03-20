import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/screens/home/settings_screen.dart';
import 'package:kozi/dashboard/job_provider/widgets/settings_icon.dart';
import '../widgets/custom_bottom_navbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Mutesi Allen');
  final _contactNumberController = TextEditingController(text: '+250180000000');
  final _dateOfBirthController = TextEditingController(text: 'DD MM YYYY');
  final _locationController = TextEditingController(text: 'Kacyiru-Kg 6470');

  @override
  void dispose() {
    _nameController.dispose();
    _contactNumberController.dispose();
    _dateOfBirthController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header Section with Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEE5A9E), Color(0xFFFF8FC8)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Top bar with back button and title
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                const Icon(Icons.arrow_back_ios_new, size: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        SettingsIconWidget(
                          iconColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile setup text
                    const Text(
                      'Set up your profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Update your profile to connect your worker with better impression.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile picture
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.teal[300],
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image:
                                  AssetImage('assets/profile_placeholder.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    _buildProfileField(
                      label: 'Name',
                      controller: _nameController,
                      readOnly: true,
                      showEdit: false,
                    ),
                    const SizedBox(height: 16),

                    // Contact Number Field
                    _buildProfileField(
                      label: 'Contact Number',
                      controller: _contactNumberController,
                      keyboardType: TextInputType.phone,
                      showEdit: true,
                      onEditPressed: () {
                        // Show edit dialog
                        _showEditDialog(
                            'Contact Number', _contactNumberController);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth Field
                    _buildProfileField(
                      label: 'Date of birth',
                      controller: _dateOfBirthController,
                      showEdit: true,
                      onEditPressed: () {
                        // Show date picker
                        _showDatePicker();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location Field
                    _buildProfileField(
                      label: 'Location',
                      controller: _locationController,
                      readOnly: true,
                      showEdit: false,
                    ),
                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Update profile logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully!')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Update',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool showEdit = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onEditPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.teal[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: TextFormField(
                  controller: controller,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: keyboardType,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              if (showEdit)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.teal[400], size: 20),
                    onPressed: onEditPressed,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String title, TextEditingController controller) {
    final TextEditingController dialogController =
        TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: dialogController,
            decoration: InputDecoration(
              hintText: 'Enter your $title',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  controller.text = dialogController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.day.toString().padLeft(2, '0')} ${picked.month.toString().padLeft(2, '0')} ${picked.year}';
      });
    }
  }
}
