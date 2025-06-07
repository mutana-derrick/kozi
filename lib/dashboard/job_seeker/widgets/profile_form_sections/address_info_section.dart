import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';
import 'package:kozi/utils/form_validation.dart';

final addressInfoErrorsProvider =
    StateProvider<Map<String, String?>>((ref) => {});

class AddressInfoSection extends ConsumerStatefulWidget {
  const AddressInfoSection({super.key});

  @override
  AddressInfoSectionState createState() => AddressInfoSectionState();
}

class AddressInfoSectionState extends ConsumerState<AddressInfoSection> {
  
  bool validateFields() {
    final ref = this.ref;
    final profile = ref.read(profileProvider);
    final errors = <String, String?>{};
    bool isValid = true;

    // Validate province
    final provinceError =
        FormValidation.validateDropdown(profile.province, 'province');
    if (provinceError != null) {
      errors['province'] = provinceError;
      isValid = false;
    }

    // Validate district
    final districtError =
        FormValidation.validateRequired(profile.district, 'District');
    if (districtError != null) {
      errors['district'] = districtError;
      isValid = false;
    }

    // Validate sector
    final sectorError =
        FormValidation.validateRequired(profile.sector, 'Sector');
    if (sectorError != null) {
      errors['sector'] = sectorError;
      isValid = false;
    }

    // Validate cell
    final cellError = FormValidation.validateRequired(profile.cell, 'Cell');
    if (cellError != null) {
      errors['cell'] = cellError;
      isValid = false;
    }

    // Validate village
    final villageError =
        FormValidation.validateRequired(profile.village, 'Village');
    if (villageError != null) {
      errors['village'] = villageError;
      isValid = false;
    }

    ref.read(addressInfoErrorsProvider.notifier).state = errors;
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final errors = ref.watch(addressInfoErrorsProvider);

    return Form(
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

          // Province
          buildDropdownField(
            context,
            label: 'Province',
            value: profile.province.isEmpty ? 'Select Province' : profile.province,
            items: const ['Kigali', 'Northern', 'Southern', 'Eastern', 'Western'],
            errorText: errors['province'],
            isRequired: true,
            onChanged: (value) {
              if (value != null) {
                ref.read(profileProvider.notifier).updateProvince(value);
                final currentErrors = {...ref.read(addressInfoErrorsProvider)};
                currentErrors.remove('province');
                ref.read(addressInfoErrorsProvider.notifier).state = currentErrors;
              }
            },
          ),
          const SizedBox(height: 16),

          // District
          buildEditableField(
            label: 'District',
            value: profile.district,
            errorText: errors['district'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateDistrict(val);
              final currentErrors = {...ref.read(addressInfoErrorsProvider)};
              currentErrors.remove('district');
              ref.read(addressInfoErrorsProvider.notifier).state = currentErrors;
            },
          ),
          const SizedBox(height: 16),

          // Sector
          buildEditableField(
            label: 'Sector',
            value: profile.sector,
            errorText: errors['sector'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateSector(val);
              final currentErrors = {...ref.read(addressInfoErrorsProvider)};
              currentErrors.remove('sector');
              ref.read(addressInfoErrorsProvider.notifier).state = currentErrors;
            },
          ),
          const SizedBox(height: 16),

          // Cell
          buildEditableField(
            label: 'Cell',
            value: profile.cell,
            errorText: errors['cell'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateCell(val);
              final currentErrors = {...ref.read(addressInfoErrorsProvider)};
              currentErrors.remove('cell');
              ref.read(addressInfoErrorsProvider.notifier).state = currentErrors;
            },
          ),
          const SizedBox(height: 16),

          // Village
          buildEditableField(
            label: 'Village',
            value: profile.village,
            errorText: errors['village'],
            isRequired: true,
            onChanged: (val) {
              ref.read(profileProvider.notifier).updateVillage(val);
              final currentErrors = {...ref.read(addressInfoErrorsProvider)};
              currentErrors.remove('village');
              ref.read(addressInfoErrorsProvider.notifier).state = currentErrors;
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String? errorText,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = TextEditingController(text: value);
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
              suffixIcon: hasError ? const Icon(Icons.error, color: ValidationColors.errorRed) : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: hasError ? ValidationColors.errorRed : const Color(0xFF5C6BC0),
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
                        color: hasError ? ValidationColors.errorRed : const Color(0xFF5C6BC0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (hasError)
                    const Icon(Icons.error, color: ValidationColors.errorRed, size: 20),
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