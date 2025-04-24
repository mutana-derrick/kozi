import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/authentication/job_seeker/providers/category_provider.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';


class TechnicalFormSection extends ConsumerStatefulWidget {
  const TechnicalFormSection({super.key});

  @override
  ConsumerState<TechnicalFormSection> createState() =>
      _TechnicalFormSectionState();
}

class _TechnicalFormSectionState extends ConsumerState<TechnicalFormSection> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitProfile() async {
    final profileState = ref.read(profileProvider);
    final apiService = ref.read(apiServiceProvider);

    // Basic validation
    if (profileState.expectedSalary.isEmpty ||
        profileState.category.isEmpty ||
        profileState.skills.isEmpty ||
        profileState.newIdCardPath.isEmpty ||
        profileState.profileImagePath.isEmpty ||
        profileState.cvPath.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await apiService.getUserId();
      if (userId == null) {
        setState(() {
          _errorMessage = 'User ID not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }

      // Prepare the data
      final data = {
        'first_name': profileState.firstName,
        'last_name': profileState.lastName,
        'gender': profileState.gender,
        'fathers_name': profileState.fathersName,
        'mothers_name': profileState.mothersName,
        'telephone': profileState.telephone,
        'province': profileState.province,
        'district': profileState.district,
        'sector': profileState.sector,
        'cell': profileState.cell,
        'village': profileState.village,
        'date_of_birth': profileState.dateOfBirth,
        'disability': profileState.disability,
        'salary': profileState.expectedSalary,
        'bio': profileState.skills,
        'categories_id': getCategoryId(profileState.category),
        'image': profileState.profileImagePath,
        'id': profileState.newIdCardPath,
        'cv': profileState.cvPath,
      };

      final result = await apiService.updateUserProfile(userId, data);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          context.go('/seekerdashboardscreen');
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  // Helper method to get category ID - in a real app, you would have a proper mapping
  String getCategoryId(String categoryName) {
    // This is a placeholder - in a real app, you would have a mapping or API call
    final Map<String, String> categoryMap = {
      'Basic Worker': '1',
      'Advanced Worker': '2',
    };

    return categoryMap[categoryName] ?? '1';
  }

  // Image picker
  Future<String?> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (image != null) {
        return image.path;
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
      return null;
    }
  }

  // File picker
  Future<String?> _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    // Categories from API - Move this line here
    final categoriesAsync = ref.watch(categoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Technical Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),

        // Display error message if any
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),

        // Expected Salary
        buildDropdownField(
          context,
          label: 'Expected Salary',
          value: profileState.expectedSalary.isEmpty
              ? 'Select Expected Salary'
              : profileState.expectedSalary,
          items: const [
            '35000RWF-99000RWF',
            '159000RWF-199000RWF',
            '200000RWF-299000RWF'
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(profileProvider.notifier).updateExpectedSalary(value);
            }
          },
        ),
        const SizedBox(height: 16),

        // Category
        // Category
        categoriesAsync.when(
          data: (categories) {
            final categoryNames = getAllCategoryNames(categories);

            return buildDropdownField(
              context,
              label: 'Category',
              value: profileState.category.isEmpty
                  ? 'Select Category'
                  : profileState.category,
              items: categoryNames.isEmpty
                  ? ['Basic Worker', 'Advanced Worker'] // Fallback
                  : categoryNames,
              onChanged: (value) {
                if (value != null) {
                  ref.read(profileProvider.notifier).updateCategory(value);
                }
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => buildDropdownField(
            context,
            label: 'Category',
            value: profileState.category.isEmpty
                ? 'Select Category'
                : profileState.category,
            items: const ['Basic Worker', 'Advanced Worker'], // Fallback
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateCategory(value);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        // Skills and Capabilities
        buildMultilineFormField(
          context,
          label: 'Elaborate your Skills and Capabilities',
          value: profileState.skills,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateSkills(value),
          maxLines: 5,
        ),
        const SizedBox(height: 16),

        // ID Card Upload
        buildFileUploadField(
          context,
          label: 'ID Card',
          fileName: profileState.newIdCardPath.isEmpty
              ? 'No file chosen'
              : profileState.newIdCardPath.split('/').last,
          onTap: () async {
            final filePath = await _pickImage(context);
            if (filePath != null) {
              ref.read(profileProvider.notifier).updateNewIdCardPath(filePath);
            }
          },
        ),
        const SizedBox(height: 16),

        // Profile Image Upload
        buildFileUploadField(
          context,
          label: 'Profile Image',
          fileName: profileState.profileImagePath.isEmpty
              ? 'No file chosen'
              : profileState.profileImagePath.split('/').last,
          onTap: () async {
            final filePath = await _pickImage(context);
            if (filePath != null) {
              ref
                  .read(profileProvider.notifier)
                  .updateProfileImagePath(filePath);
            }
          },
        ),
        const SizedBox(height: 16),

        // CV Upload
        buildFileUploadField(
          context,
          label: 'Upload your CV',
          fileName: profileState.cvPath.isEmpty
              ? 'No file chosen'
              : profileState.cvPath.split('/').last,
          onTap: () async {
            final filePath = await _pickFile(context);
            if (filePath != null) {
              ref.read(profileProvider.notifier).updateCvPath(filePath);
            }
          },
        ),
        const SizedBox(height: 24),

        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(color: Color(0xFFEA60A7)),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        ref.read(profileProvider.notifier).goToPreviousStep();
                      },
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Color(0xFFEA60A7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _submitProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Reusing your existing widget methods
  Widget buildMultilineFormField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    final TextEditingController controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 78, 80, 80),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF5C6BC0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFileUploadField(
    BuildContext context, {
    required String label,
    required String fileName,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 78, 80, 80),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                child: Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5C6BC0),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: onTap,
              child: const Text(
                'Choose File',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDropdownField(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 78, 80, 80),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              hint: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5C6BC0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF5C6BC0)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF5C6BC0),
                fontWeight: FontWeight.w400,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5C6BC0),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
