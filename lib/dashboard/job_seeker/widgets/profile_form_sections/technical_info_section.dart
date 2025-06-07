import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/authentication/job_seeker/providers/category_provider.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

final technicalInfoErrorsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

class TechnicalInfoSection extends ConsumerStatefulWidget {
  const TechnicalInfoSection({super.key});

  @override
  ConsumerState<TechnicalInfoSection> createState() =>
      TechnicalInfoSectionState();
}

class TechnicalInfoSectionState extends ConsumerState<TechnicalInfoSection> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load category types when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryTypesProvider);
    });
  }

  bool validateFields() {
    final profile = ref.read(profileProvider);
    final errors = <String, String?>{};
    bool isValid = true;

    // Validate expected salary
    final salaryError = FormValidation.validateDropdown(
        profile.expectedSalary, 'expected salary');
    if (salaryError != null) {
      errors['expectedSalary'] = salaryError;
      isValid = false;
    }

    // Validate category
    final categoryError =
        FormValidation.validateDropdown(profile.category, 'category');
    if (categoryError != null) {
      errors['category'] = categoryError;
      isValid = false;
    }

    // Validate skills
    final skillsError =
        FormValidation.validateRequired(profile.skills, 'Skills');
    if (skillsError != null) {
      errors['skills'] = skillsError;
      isValid = false;
    }

    // Validate ID Card
    final idCardError =
        FormValidation.validateRequired(profile.newIdCardPath, 'ID Card');
    if (idCardError != null) {
      errors['newIdCardPath'] = idCardError;
      isValid = false;
    }

    // Validate Profile Image
    final profileImageError = FormValidation.validateRequired(
        profile.profileImagePath, 'Profile Image');
    if (profileImageError != null) {
      errors['profileImagePath'] = profileImageError;
      isValid = false;
    }

    // Validate CV
    final cvError =
        FormValidation.validateRequired(profile.cvPath, 'CV/Resume');
    if (cvError != null) {
      errors['cvPath'] = cvError;
      isValid = false;
    }

    ref.read(technicalInfoErrorsProvider.notifier).state = errors;
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
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
            value: profile.expectedSalary.isEmpty
                ? 'Select Expected Salary'
                : profile.expectedSalary,
            items: const [
              '35000RWF-99000RWF',
              '100000RWF-149000RWF',
              '150000RWF-199000RWF',
              '200000RWF-299000RWF',
              '300000RWF +'
            ],
            errorText: errors['expectedSalary'],
            isRequired: true,
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateExpectedSalary(value);
                final currentErrors = {
                  ...ref.read(technicalInfoErrorsProvider)
                };
                currentErrors.remove('expectedSalary');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
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
              value: profile.category.isEmpty
                  ? 'Select Category'
                  : profile.category,
              items: filteredCategories
                  .map((cat) => cat['name'] as String)
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(profileProvider.notifier).updateCategory(value);
                  final currentErrors = {
                    ...ref.read(technicalInfoErrorsProvider)
                  };
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
            value: profile.skills,
            errorText: errors['skills'],
            isRequired: true,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateSkills(value);
              final currentErrors = {...ref.read(technicalInfoErrorsProvider)};
              currentErrors.remove('skills');
              ref.read(technicalInfoErrorsProvider.notifier).state =
                  currentErrors;
            },
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // File uploads
          buildFileUploadField(
            context,
            label: 'ID Card',
            fileName: profile.newIdCardPath.isEmpty
                ? 'No file chosen'
                : profile.newIdCardPath.split('/').last,
            errorText: errors['newIdCardPath'],
            isRequired: true,
            onTap: () {
              _pickImage(context, (filePath) {
                ref
                    .read(profileProvider.notifier)
                    .updateNewIdCardPath(filePath);
                final currentErrors = {
                  ...ref.read(technicalInfoErrorsProvider)
                };
                currentErrors.remove('newIdCardPath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
          ),
          const SizedBox(height: 16),

          buildFileUploadField(
            context,
            label: 'Profile Image',
            fileName: profile.profileImagePath.isEmpty
                ? 'No file chosen'
                : profile.profileImagePath.split('/').last,
            errorText: errors['profileImagePath'],
            isRequired: true,
            onTap: () {
              _pickImage(context, (filePath) {
                ref
                    .read(profileProvider.notifier)
                    .updateProfileImagePath(filePath);
                final currentErrors = {
                  ...ref.read(technicalInfoErrorsProvider)
                };
                currentErrors.remove('profileImagePath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
          ),
          const SizedBox(height: 16),

          buildFileUploadField(
            context,
            label: 'CV/Resume',
            fileName: profile.cvPath.isEmpty
                ? 'No file chosen'
                : profile.cvPath.split('/').last,
            errorText: errors['cvPath'],
            isRequired: true,
            onTap: () {
              _pickFile(context, (filePath) {
                ref.read(profileProvider.notifier).updateCvPath(filePath);
                final currentErrors = {
                  ...ref.read(technicalInfoErrorsProvider)
                };
                currentErrors.remove('cvPath');
                ref.read(technicalInfoErrorsProvider.notifier).state =
                    currentErrors;
              });
            },
          ),
          // Removed navigation buttons - they are now handled by the parent screen
        ],
      ),
    );
  }

  // File pickers with proper image picker and file picker implementation
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
    String? errorText,
    bool isRequired = false,
    int maxLines = 1,
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
