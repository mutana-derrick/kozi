// lib/authentication/job_seeker/widgets/profile_form_sections/personal_info_form_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    // Validate father's name
    final fathersNameError = FormValidation.validateRequired(
        profileState.fathersName, 'Father\'s name');
    if (fathersNameError != null) {
      errorsMap['fathersName'] = fathersNameError;
      isValid = false;
    }

    // Validate mother's name
    final mothersNameError = FormValidation.validateRequired(
        profileState.mothersName, 'Mother\'s name');
    if (mothersNameError != null) {
      errorsMap['mothersName'] = mothersNameError;
      isValid = false;
    }

    // Validate date of birth
    final dobError = FormValidation.validateRequired(
        profileState.dateOfBirth, 'Date of birth');
    if (dobError != null || profileState.dateOfBirth == 'DD/MM/YYYY') {
      errorsMap['dateOfBirth'] = 'Date of birth is required';
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

    // Update the errors provider
    ref.read(personalInfoErrorsProvider.notifier).state = errorsMap;

    return isValid;
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
            onChanged: (value) =>
                ref.read(profileProvider.notifier).updateFirstName(value),
            errorText: errors['firstName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Last Name
          buildEditableFormField(
            context,
            label: 'Last Name',
            value: profileState.lastName,
            onChanged: (value) =>
                ref.read(profileProvider.notifier).updateLastName(value),
            errorText: errors['lastName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Father's Name
          buildEditableFormField(
            context,
            label: 'Father\'s Name',
            value: profileState.fathersName,
            onChanged: (value) =>
                ref.read(profileProvider.notifier).updateFathersName(value),
            errorText: errors['fathersName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Mother's Name
          buildEditableFormField(
            context,
            label: 'Mother\'s Name',
            value: profileState.mothersName,
            onChanged: (value) =>
                ref.read(profileProvider.notifier).updateMothersName(value),
            errorText: errors['mothersName'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Date of Birth
          buildDatePickerField(
            context,
            ref,
            label: 'Date of Birth',
            value: profileState.dateOfBirth,
            errorText: errors['dateOfBirth'],
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
            onChanged: (value) =>
                ref.read(profileProvider.notifier).updateTelephone(value),
            keyboardType: TextInputType.phone,
            errorText: errors['telephone'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Disability dropdown
          buildDropdownField(
            context,
            label: 'Do you have any Disability?',
            value: profileState.disability,
            items: const [
              'None',
              'Visual Impairment',
              'Hearing Impairment',
              'Physical Disability',
              'Intellectual Disability',
              'Mental Health Condition',
              'Learning Disability',
              'Speech and Language Disorder',
              'Other'
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateDisability(value);
              }
            },
            isRequired: false,
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
            onChanged: (value) {
              onChanged(value);
              // Clear error when typing
              if (hasError) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(personalInfoErrorsProvider));
                if (label == 'First Name') currentErrors.remove('firstName');
                if (label == 'Last Name') currentErrors.remove('lastName');
                if (label == 'Father\'s Name') {
                  currentErrors.remove('fathersName');
                }
                if (label == 'Mother\'s Name') {
                  currentErrors.remove('mothersName');
                }
                if (label == 'Telephone') currentErrors.remove('telephone');
                ref.read(personalInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
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

Widget buildDatePickerField(
  BuildContext context,
  WidgetRef ref, {
  required String label,
  required String value,
  String? errorText,
  bool isRequired = false,
}) {
  final hasError = errorText != null;

  // Function to convert API date format to a more readable display format
  String formatDateForDisplay(String dateString) {
    // Default display text if date is not set or invalid
    if (dateString == 'DD/MM/YYYY' || 
        dateString == '0000-00-00' || 
        dateString.startsWith('0000-00-00')) {
      return 'Select Date';
    }
    
    try {
      // Handle ISO format (1899-11-29T22:30:00.000Z)
      if (dateString.contains('T')) {
        final parsedDate = DateTime.parse(dateString);
        return "${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}";
      }
      
      // Handle yyyy-mm-dd format
      if (dateString.contains('-') && dateString.length >= 10) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          return "${parts[2]}/${parts[1]}/${parts[0]}"; // dd/mm/yyyy format for display
        }
      }
      
      // Handle dd/mm/yyyy format (already in display format)
      if (dateString.contains('/') && dateString.length >= 10) {
        return dateString; // Already in display format
      }
    } catch (e) {
      print('Error parsing date for display: $e');
    }
    
    // Return original value if it's not in expected format or parsing fails
    return dateString;
  }

  // Get display value 
  final displayValue = formatDateForDisplay(value);

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
      InkWell(
        onTap: () async {
          final DateTime today = DateTime.now();
          final DateTime latestValidDOB =
              DateTime(today.year - 18, today.month, today.day);
          final DateTime firstAllowedDate = DateTime(1900, 1, 1);
          
          // Determine initial date
          DateTime initialDate = latestValidDOB;
          
          // Try to parse the existing value if it's valid
          if (value != 'DD/MM/YYYY' && 
              value != 'Select Date' && 
              value != '0000-00-00' && 
              !value.startsWith('0000-00-00')) {
            try {
              // Try to parse ISO format with time
              if (value.contains('T')) {
                final tempDate = DateTime.parse(value);
                
                // Ensure the parsed date is valid and within allowed range
                if (!tempDate.isBefore(firstAllowedDate) && !tempDate.isAfter(latestValidDOB)) {
                  initialDate = tempDate;
                }
              } 
              // Try to parse yyyy-mm-dd format
              else if (value.contains('-')) {
                final tempDate = DateTime.parse(value);
                
                // Ensure the parsed date is valid and within allowed range
                if (!tempDate.isBefore(firstAllowedDate) && !tempDate.isAfter(latestValidDOB)) {
                  initialDate = tempDate;
                }
              }
              // Try to parse dd/mm/yyyy format
              else if (value.contains('/')) {
                final parts = value.split('/');
                if (parts.length == 3) {
                  final tempDate = DateTime(
                    int.parse(parts[2]),  // year
                    int.parse(parts[1]),  // month
                    int.parse(parts[0]),  // day
                  );
                  
                  // Ensure the parsed date is valid and within allowed range
                  if (!tempDate.isBefore(firstAllowedDate) && !tempDate.isAfter(latestValidDOB)) {
                    initialDate = tempDate;
                  }
                }
              }
            } catch (e) {
              print('Error parsing date for picker: $e');
              // Keep default initialDate if parsing fails
            }
          }
          
          try {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstAllowedDate,
              lastDate: latestValidDOB,
            );

            if (picked != null) {
              // Format in yyyy-mm-dd format for storage
              final formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              
              ref
                  .read(profileProvider.notifier)
                  .updateDateOfBirth(formattedDate);

              // Clear error when selected
              final currentErrors = Map<String, String?>.from(
                  ref.read(personalInfoErrorsProvider));
              currentErrors.remove('dateOfBirth');
              ref.read(personalInfoErrorsProvider.notifier).state =
                  currentErrors;
            }
          } catch (e) {
            print('Error showing date picker: $e');
            // Show a snackbar with error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error selecting date: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasError ? ValidationColors.errorRed : Colors.transparent,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayValue, // Show formatted date in display format
                style: TextStyle(
                  fontSize: 16,
                  color: hasError
                      ? ValidationColors.errorRed
                      : (displayValue == 'Select Date' 
                          ? Colors.grey[600] 
                          : const Color(0xFF5C6BC0)),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Row(
                children: [
                  if (hasError)
                    const Icon(Icons.error,
                        color: ValidationColors.errorRed, size: 20),
                  const SizedBox(width: 8),
                  const FaIcon(
                    FontAwesomeIcons.calendar,
                    size: 18,
                    color: Color(0xFF5C6BC0),
                  ),
                ],
              ),
            ],
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
