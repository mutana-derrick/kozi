import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_provider/providers/auth_provider.dart';
import 'package:kozi/utils/form_validation.dart';
import '../../providers/profile_provider.dart';

// Provider to track form validation errors
final addressInfoErrorsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

class AddressFormSection extends ConsumerStatefulWidget {
  const AddressFormSection({super.key});

  @override
  ConsumerState<AddressFormSection> createState() => _AddressFormSectionState();
}

class _AddressFormSectionState extends ConsumerState<AddressFormSection> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Method to validate all fields before proceeding or submitting
  bool _validateFields() {
    bool isValid = true;
    final profileState = ref.read(profileProvider);
    final errorsMap = <String, String?>{};

    // Validate province
    final provinceError =
        FormValidation.validateDropdown(profileState.province, 'province');
    if (provinceError != null) {
      errorsMap['province'] = provinceError;
      isValid = false;
    }

    // Validate district
    final districtError =
        FormValidation.validateRequired(profileState.district, 'District');
    if (districtError != null) {
      errorsMap['district'] = districtError;
      isValid = false;
    }

    // Validate sector
    final sectorError =
        FormValidation.validateRequired(profileState.sector, 'Sector');
    if (sectorError != null) {
      errorsMap['sector'] = sectorError;
      isValid = false;
    }

    // Validate cell
    final cellError =
        FormValidation.validateRequired(profileState.cell, 'Cell');
    if (cellError != null) {
      errorsMap['cell'] = cellError;
      isValid = false;
    }

    // Validate village
    final villageError =
        FormValidation.validateRequired(profileState.village, 'Village');
    if (villageError != null) {
      errorsMap['village'] = villageError;
      isValid = false;
    }

    // Update the errors provider
    ref.read(addressInfoErrorsProvider.notifier).state = errorsMap;

    return isValid;
  }

  void _goToPrevious() {
    ref.read(profileProvider.notifier).goToPreviousStep();
  }

  Future<void> _submitProfile(BuildContext context) async {
    // Validate fields first
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final profileState = ref.read(profileProvider);
      final userId = await apiService.getUserId();

      if (userId == null) {
        throw Exception("User ID not found");
      }

      // Create data for API request
      final data = {
        'first_name': profileState.firstName,
        'last_name': profileState.lastName,
        'gender': profileState.gender,
        'email': '', // You might need to get this from elsewhere
        'password': '', // You might need to handle this differently
        'full_name': '${profileState.firstName} ${profileState.lastName}',
        'telephone': profileState.telephone,
        'province': profileState.province,
        'district': profileState.district,
        'sector': profileState.sector,
        'cell': profileState.cell,
        'village': profileState.village,
        'date_of_birth': profileState.dateOfBirth,
        'id': profileState.id, // Make sure this matches your backend
        'description':
            profileState.description, // Or any other description field
      };

      // Send update request
      final result = await apiService.updateProviderProfile(userId, data);

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to dashboard
          if (context.mounted) {
            context.go('/providerdashboardscreen');
          }
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final errors = ref.watch(addressInfoErrorsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ValidationColors.errorRedLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ValidationColors.errorRedBorder),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: ValidationColors.errorRed,
                  fontSize: 14,
                ),
              ),
            ),

          // Province
          buildDropdownField(
            context,
            label: 'Province',
            value: profileState.province.isEmpty
                ? 'Select Province'
                : profileState.province,
            items: const [
              'Kigali',
              'Northern',
              'Southern',
              'Eastern',
              'Western'
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateProvince(value);
                // Clear error when selected
                final currentErrors = Map<String, String?>.from(
                    ref.read(addressInfoErrorsProvider));
                currentErrors.remove('province');
                ref.read(addressInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['province'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // District
          buildEditableFormField(
            context,
            label: 'District',
            value: profileState.district,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateDistrict(value);
              // Clear error when typing
              if (errors['district'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(addressInfoErrorsProvider));
                currentErrors.remove('district');
                ref.read(addressInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['district'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Sector
          buildEditableFormField(
            context,
            label: 'Sector',
            value: profileState.sector,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateSector(value);
              // Clear error when typing
              if (errors['sector'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(addressInfoErrorsProvider));
                currentErrors.remove('sector');
                ref.read(addressInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['sector'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Cell
          buildEditableFormField(
            context,
            label: 'Cell',
            value: profileState.cell,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateCell(value);
              // Clear error when typing
              if (errors['cell'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(addressInfoErrorsProvider));
                currentErrors.remove('cell');
                ref.read(addressInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['cell'],
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Village
          buildEditableFormField(
            context,
            label: 'Village',
            value: profileState.village,
            onChanged: (value) {
              ref.read(profileProvider.notifier).updateVillage(value);
              // Clear error when typing
              if (errors['village'] != null) {
                final currentErrors = Map<String, String?>.from(
                    ref.read(addressInfoErrorsProvider));
                currentErrors.remove('village');
                ref.read(addressInfoErrorsProvider.notifier).state =
                    currentErrors;
              }
            },
            errorText: errors['village'],
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
