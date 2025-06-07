import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kozi/utils/form_validation.dart';
import '../../providers/profile_provider.dart';

// Provider to track form validation errors
final personalInfoErrorsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

class PersonalInfoFormSection extends ConsumerStatefulWidget {
  const PersonalInfoFormSection({super.key});

  @override
  ConsumerState<PersonalInfoFormSection> createState() =>
      _PersonalInfoFormSectionState();
}

class _PersonalInfoFormSectionState
    extends ConsumerState<PersonalInfoFormSection> {
  final _formKey = GlobalKey<FormState>();

  // Method to validate all fields before proceeding
  bool _validateFields() {
    bool isValid = true;
    final profileState = ref.read(profileProvider);
    final errorsMap = <String, String?>{};

    // Validate first name
    final firstNameError =
        FormValidation.validateRequired(profileState.firstName, 'First name');
    if (firstNameError != null) {
      errorsMap['firstName'] = firstNameError;
      isValid = false;
    }

    // Validate last name
    final lastNameError =
        FormValidation.validateRequired(profileState.lastName, 'Last name');
    if (lastNameError != null) {
      errorsMap['lastName'] = lastNameError;
      isValid = false;
    }

    // Validate gender
    final genderError =
        FormValidation.validateDropdown(profileState.gender, 'gender');
    if (genderError != null) {
      errorsMap['gender'] = genderError;
      isValid = false;
    }

    // Validate telephone
    final telephoneError = FormValidation.validatePhone(profileState.telephone);
    if (telephoneError != null) {
      errorsMap['telephone'] = telephoneError;
      isValid = false;
    }

    // Validate category
    final categoryError =
        FormValidation.validateDropdown(profileState.category, 'category');
    if (categoryError != null) {
      errorsMap['category'] = categoryError;
      isValid = false;
    }

    // Profile image is now optional, so no validation needed

    // Update the errors provider
    ref.read(personalInfoErrorsProvider.notifier).state = errorsMap;

    return isValid;
  }

  Future<void> _pickProfileImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(profileProvider.notifier).updateProfileImagePath(image.path);

        // Clear error when file is selected
        final currentErrors =
            Map<String, String?>.from(ref.read(personalInfoErrorsProvider));
        currentErrors.remove('profileImage');
        ref.read(personalInfoErrorsProvider.notifier).state = currentErrors;
      }
    } catch (e) {
      // Update error state
      final currentErrors =
          Map<String, String?>.from(ref.read(personalInfoErrorsProvider));
      currentErrors['profileImage'] = 'Error picking image: $e';
      ref.read(personalInfoErrorsProvider.notifier).state = currentErrors;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _goToNext() {
    if (_validateFields()) {
      ref.read(profileProvider.notifier).goToNextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final errors = ref.watch(personalInfoErrorsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // First Name
          buildEditableFormField(
            context,
            label: 'First Name',
            value: profileState.firstName,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateFirstName(value);
              // Clear error when typing
              if (errors['firstName'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                currentErrors.remove('firstName');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['firstName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Last Name
          buildEditableFormField(
            context,
            label: 'Last Name',
            value: profileState.lastName,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateLastName(value);
              // Clear error when typing
              if (errors['lastName'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                currentErrors.remove('lastName');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['lastName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Gender
          buildDropdownField(
            context,
            label: 'Gender',
            value: profileState.gender.isEmpty
                ? 'Select Gender'
                : profileState.gender,
            items: const ['Male', 'Female', 'Other'],
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateGender(value);
                // Clear error when selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                currentErrors.remove('gender');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['gender'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Telephone
          buildEditableFormField(
            context,
            label: 'Telephone',
            value: profileState.telephone,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateTelephone(value);
              // Clear error when typing
              if (errors['telephone'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                currentErrors.remove('telephone');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            keyboardType: TextInputType.phone,
            errorText: errors['telephone'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Category
          buildDropdownField(
            context,
            label: 'Category',
            value: profileState.category.isEmpty
                ? 'Select Category'
                : profileState.category,
            items: const ['individual', 'company'],
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateCategory(value);
                // Clear error when selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                currentErrors.remove('category');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['category'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Profile Image Upload Field (now optional)
          buildFileUploadField(
            context,
            label: 'Profile Photo (Optional)',
            fileName: profileState.profileImagePath.isEmpty
                ? 'No file chosen'
                : profileState.profileImagePath.split('/').last,
            onTap: _pickProfileImage,
            errorText: errors['profileImage'],
            isRequired: false, // Changed to false
          ),
          const SizedBox(height: 24),

          // Next button
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: _goToNext,
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget buildEditableFormField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
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
            keyboardType: keyboardType,
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
