// lib/dashboard/job_seeker/widgets/profile_form_sections/technical_info_section.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/authentication/job_seeker/providers/category_provider.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// Provider to track form validation errors
final technicalInfoErrorsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

class TechnicalInfoSection extends ConsumerStatefulWidget {
  const TechnicalInfoSection({super.key});

  @override
  ConsumerState<TechnicalInfoSection> createState() =>
      _TechnicalInfoSectionState();
}

class _TechnicalInfoSectionState extends ConsumerState<TechnicalInfoSection> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load category types when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryTypesProvider);
    });
  }

  // Method to validate all fields before proceeding
  bool _validateFields() {
    bool isValid = true;
    final profileState = ref.read(profileProvider);
    final errorsMap = <String, String?>{};

    // Validate expected salary
    final salaryError = FormValidation.validateDropdown(
        profileState.expectedSalary, 'expected salary');
    if (salaryError != null) {
      errorsMap['expectedSalary'] = salaryError;
      isValid = false;
    }

    // Validate category
    final categoryError =
        FormValidation.validateDropdown(profileState.category, 'category');
    if (categoryError != null) {
      errorsMap['category'] = categoryError;
      isValid = false;
    }

    // Validate skills
    final skillsError =
        FormValidation.validateRequired(profileState.skills, 'Skills');
    if (skillsError != null) {
      errorsMap['skills'] = skillsError;
      isValid = false;
    }

    // Validate ID Card
    final idCardError =
        FormValidation.validateRequired(profileState.newIdCardPath, 'ID Card');
    if (idCardError != null) {
      errorsMap['newIdCardPath'] = idCardError;
      isValid = false;
    }

    // Validate Profile Image
    final profileImageError = FormValidation.validateRequired(
        profileState.profileImagePath, 'Profile Image');
    if (profileImageError != null) {
      errorsMap['profileImagePath'] = profileImageError;
      isValid = false;
    }

    // Validate CV
    final cvError =
        FormValidation.validateRequired(profileState.cvPath, 'CV/Resume');
    if (cvError != null) {
      errorsMap['cvPath'] = cvError;
      isValid = false;
    }

    // Update the errors provider
    ref.read(technicalInfoErrorsProvider.notifier).state = errorsMap;

    return isValid;
  }

  void _goToPrevious() {
    ref.read(profileProvider.notifier).goToPreviousStep();
  }

  Future<void> _submitProfile(BuildContext context) async {
    // Validate all fields first
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Submit profile data
    final success = await ref.read(profileProvider.notifier).submitProfile();

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to dashboard using GoRouter
      if (context.mounted) {
        context.go('/seekerdashboardscreen');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final errors = ref.watch(technicalInfoErrorsProvider);

    // Watch category data
    final categoryTypesAsync = ref.watch(categoryTypesProvider);
    final selectedCategoryType = ref.watch(selectedCategoryTypeProvider);
    final filteredCategories = ref.watch(filteredCategoriesProvider);

    return Form(
      key: _formKey,
      child: Column(
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

          // Expected Salary
          buildDropdownField(
            context,
            label: 'Expected Salary',
            value: profileState.expectedSalary.isEmpty
                ? 'Select Expected Salary'
                : profileState.expectedSalary,
            items: const [
              '35000RWF-99000RWF',
              '100000RWF-149000RWF',
              '150000RWF-199000RWF',
              '200000RWF-299000RWF',
              '300000RWF and above'
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateExpectedSalary(value);
                // Clear error when selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(technicalInfoErrorsProvider));
                currentErrors.remove('expectedSalary');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['expectedSalary'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Category Type dropdown
          categoryTypesAsync.when(
            data: (categoryTypes) {
              final typeNames = getAllCategoryTypeNames(categoryTypes);
              return buildDropdownField(
                context,
                label: 'Category Type',
                value: selectedCategoryType != null
                    ? categoryTypes.firstWhere(
                          (type) =>
                              type['type_id'].toString() ==
                              selectedCategoryType,
                          orElse: () => {'type_name': 'Select Category Type'},
                        )['type_name'] ??
                        'Select Category Type'
                    : 'Select Category Type',
                items: typeNames,
                onChanged: (value) {
                  if (value != null) {
                    // Find the type ID corresponding to the selected name
                    final typeId =
                        getCategoryTypeIdByName(categoryTypes, value);
                    if (typeId != null) {
                      ref.read(selectedCategoryTypeProvider.notifier).state =
                          typeId;
                    }
                  }
                },
                errorText: null,
                isRequired: true,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Failed to load category types'),
          ),
          const SizedBox(height: 16),

          // Category dropdown (depends on selected category type)
          if (selectedCategoryType != null)
            buildDropdownField(
              context,
              label: 'Category',
              value: profileState.category.isEmpty
                  ? 'Select Category'
                  : profileState.category,
              items: filteredCategories
                  .map((cat) => cat['name'] as String)
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(profileProvider.notifier).updateCategory(value);
                  // Clear error when selected
                  final currentErrors = Map<String, String?>.from(
                      ref.read(technicalInfoErrorsProvider));
                  currentErrors.remove('category');
                  ref.read(technicalInfoErrorsProvider.notifier).state =
                      currentErrors;
                }
              },
              errorText: errors['category'],
              isRequired: true,
            ),
          const SizedBox(height: 16),

          // Skills and Capabilities
          buildMultilineFormField(
            context,
            label: 'Skills and Capabilities',
            value: profileState.skills,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateSkills(value);
              // Clear error when typing
              if (errors['skills'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(technicalInfoErrorsProvider));
                currentErrors.remove('skills');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            maxLines: 5,
            errorText: errors['skills'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // File uploads
          buildFileUploadField(
            context,
            label: 'ID Card',
            fileName: profileState.newIdCardPath.isEmpty
                ? 'No file chosen'
                : profileState.newIdCardPath.split('/').last,
            onTap: () {
              _pickImage(context, (filePath) {
                ref
                    .read(profileProvider.notifier)
                    .updateNewIdCardPath(filePath);
                // Clear error when file is selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(technicalInfoErrorsProvider));
                currentErrors.remove('newIdCardPath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
            errorText: errors['newIdCardPath'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          buildFileUploadField(
            context,
            label: 'Profile Image',
            fileName: profileState.profileImagePath.isEmpty
                ? 'No file chosen'
                : profileState.profileImagePath.split('/').last,
            onTap: () {
              _pickImage(context, (filePath) {
                ref
                    .read(profileProvider.notifier)
                    .updateProfileImagePath(filePath);
                // Clear error when file is selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(technicalInfoErrorsProvider));
                currentErrors.remove('profileImagePath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
            errorText: errors['profileImagePath'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          buildFileUploadField(
            context,
            label: 'CV/Resume',
            fileName: profileState.cvPath.isEmpty
                ? 'No file chosen'
                : profileState.cvPath.split('/').last,
            onTap: () {
              _pickFile(context, (filePath) {
                ref.read(profileProvider.notifier).updateCvPath(filePath);
                // Clear error when file is selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(technicalInfoErrorsProvider));
                currentErrors.remove('cvPath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
            errorText: errors['cvPath'],
            isRequired: true,
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
                  onPressed: _isSubmitting ? null : _goToPrevious,
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
                  onPressed:
                      _isSubmitting ? null : () => _submitProfile(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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
      ),
    );
  }

  // File pickers
  // In your TechnicalInfoSection.dart when picking files:
  Future<void> _pickImage(
      BuildContext context, Function(String) onPicked) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        print('Image picked: ${image.path}');
        // Verify file exists
        final file = File(image.path);
        final exists = await file.exists();
        print('File exists: $exists');
        if (exists) {
          onPicked(image.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file does not exist')),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pickFile(
      BuildContext context, Function(String) onPicked) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        onPicked(result.files.single.path!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Widget buildMultilineFormField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    String? errorText,
    bool isRequired = false,
  }) {
    final TextEditingController controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));

    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 57, 58, 58),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: ValidationColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? ValidationColors.errorRed : Colors.transparent,
              width: hasError ? 1.0 : 0,
            ),
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              suffixIcon: hasError
                  ? const Icon(Icons.error, color: ValidationColors.errorRed)
                  : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: hasError
                  ? ValidationColors.errorRed
                  : const Color(0xFF5C6BC0),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(
                color: ValidationColors.errorRed,
                fontSize: 12,
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
    String? errorText,
    bool isRequired = false,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 57, 58, 58),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: ValidationColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
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
                  border: Border.all(
                    color: hasError
                        ? ValidationColors.errorRed
                        : Colors.transparent,
                    width: hasError ? 1.0 : 0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 16,
                          color: hasError
                              ? ValidationColors.errorRed
                              : const Color(0xFF5C6BC0),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasError)
                      const Icon(Icons.error,
                          color: ValidationColors.errorRed, size: 20),
                  ],
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
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(
                color: ValidationColors.errorRed,
                fontSize: 12,
              ),
            ),
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
    String? errorText,
    bool isRequired = false,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 78, 80, 80),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: ValidationColors.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? ValidationColors.errorRed : Colors.transparent,
              width: hasError ? 1.0 : 0,
            ),
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
              hint: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: hasError
                            ? ValidationColors.errorRed
                            : const Color(0xFF5C6BC0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (hasError)
                    const Icon(Icons.error,
                        color: ValidationColors.errorRed, size: 20),
                ],
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
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 5),
            child: Text(
              errorText,
              style: const TextStyle(
                color: ValidationColors.errorRed,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
