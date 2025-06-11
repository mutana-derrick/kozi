import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/utils/form_validation.dart';

final personalInfoErrorsProvider = StateProvider<Map<String, String?>>((ref) => {});

class PersonalInfoSection extends ConsumerStatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  PersonalInfoSectionState createState() => PersonalInfoSectionState();
}

class PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _telephoneController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _telephoneController = TextEditingController(text: profile.telephone);
    _dobController = TextEditingController(text: profile.dateOfBirth);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  bool validateFields() {
    final profile = ref.read(profileProvider);
    final errors = <String, String?>{};
    bool isValid = true;

    final firstNameError =
        FormValidation.validateRequired(profile.firstName, 'First Name');
    if (firstNameError != null) {
      errors['firstName'] = firstNameError;
      isValid = false;
    }

    final lastNameError =
        FormValidation.validateRequired(profile.lastName, 'Last Name');
    if (lastNameError != null) {
      errors['lastName'] = lastNameError;
      isValid = false;
    }

    final phoneError = FormValidation.validatePhone(profile.telephone);
    if (phoneError != null) {
      errors['telephone'] = phoneError;
      isValid = false;
    }

    final dobError =
        FormValidation.validateRequired(profile.dateOfBirth, 'Date of Birth');
    if (dobError != null) {
      errors['dateOfBirth'] = dobError;
      isValid = false;
    }

    final genderError =
        FormValidation.validateDropdown(profile.gender, 'Gender');
    if (genderError != null) {
      errors['gender'] = genderError;
      isValid = false;
    }

    final disabilityError =
        FormValidation.validateDropdown(profile.disability, 'Disability');
    if (disabilityError != null) {
      errors['disability'] = disabilityError;
      isValid = false;
    }

    ref.read(personalInfoErrorsProvider.notifier).state = errors;
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final errors = ref.watch(personalInfoErrorsProvider);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          buildEditableField(
            label: 'First Name',
            controller: _firstNameController,
            errorText: errors['firstName'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateFirstName(val);
              ref.read(personalInfoErrorsProvider.notifier).update((state) {
                final updated = {...state};
                updated.remove('firstName');
                return updated;
              });
            },
          ),
          const SizedBox(height: 16),

          buildEditableField(
            label: 'Last Name',
            controller: _lastNameController,
            errorText: errors['lastName'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateLastName(val);
              ref.read(personalInfoErrorsProvider.notifier).update((state) {
                final updated = {...state};
                updated.remove('lastName');
                return updated;
              });
            },
          ),
          const SizedBox(height: 16),

          buildEditableField(
            label: 'Phone Number',
            controller: _telephoneController,
            errorText: errors['telephone'],
            isRequired: true,
            keyboardType: TextInputType.phone,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateTelephone(val);
              ref.read(personalInfoErrorsProvider.notifier).update((state) {
                final updated = {...state};
                updated.remove('telephone');
                return updated;
              });
            },
          ),
          const SizedBox(height: 16),

          buildDateField(
            label: 'Date of Birth',
            value: profile.dateOfBirth,
            controller: _dobController,
            errorText: errors['dateOfBirth'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateDateOfBirth(val);
              _dobController.text = val;
              ref.read(personalInfoErrorsProvider.notifier).update((state) {
                final updated = {...state};
                updated.remove('dateOfBirth');
                return updated;
              });
            },
          ),
          const SizedBox(height: 16),

          buildDropdownField(
            context,
            label: 'Gender',
            value: profile.gender.isEmpty ? 'Select Gender' : profile.gender,
            items: const ['Male', 'Female', 'Other'],
            errorText: errors['gender'],
            isRequired: true,
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateGender(value);
                ref.read(personalInfoErrorsProvider.notifier).update((state) {
                  final updated = {...state};
                  updated.remove('gender');
                  return updated;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          buildDropdownField(
            context,
            label: 'Do you have any Disability?',
            value: profile.disability.isEmpty
                ? 'Select Disability Status'
                : profile.disability,
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
            errorText: errors['disability'],
            isRequired: true,
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateDisability(value);
                ref.read(personalInfoErrorsProvider.notifier).update((state) {
                  final updated = {...state};
                  updated.remove('disability');
                  return updated;
                });
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? errorText,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
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

  Widget buildDateField({
    required String label,
    required String value,
    required TextEditingController controller,
    required Function(String) onChanged,
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
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: value.isNotEmpty
                    ? DateTime.tryParse(value) ?? DateTime.now()
                    : DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFFEA60A7),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                final formattedDate =
                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                onChanged(formattedDate);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Select Date of Birth' : value,
                      style: TextStyle(
                        fontSize: 16,
                        color: hasError
                            ? ValidationColors.errorRed
                            : value.isEmpty
                                ? Colors.grey[600]
                                : const Color(0xFF5C6BC0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Icon(
                    hasError ? Icons.error : Icons.calendar_today,
                    color: hasError
                        ? ValidationColors.errorRed
                        : const Color(0xFF5C6BC0),
                    size: 20,
                  ),
                ],
              ),
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
              hint: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: hasError
                      ? ValidationColors.errorRed
                      : const Color(0xFF5C6BC0),
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
