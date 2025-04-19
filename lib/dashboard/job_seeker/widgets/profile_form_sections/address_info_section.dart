import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';

class AddressInfoSection extends ConsumerWidget {
  const AddressInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

    return Column(
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
          value: profileState.province.isEmpty
              ? 'Select Province'
              : profileState.province,
          items: const ['Kigali', 'Northern', 'Southern', 'Eastern', 'Western'],
          onChanged: (value) {
            if (value != null) {
              ref.read(profileProvider.notifier).updateProvince(value);
            }
          },
        ),
        const SizedBox(height: 16),

        // District
        buildEditableFormField(
          context,
          label: 'District',
          value: profileState.district,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateDistrict(value),
        ),
        const SizedBox(height: 16),

        // Sector
        buildEditableFormField(
          context,
          label: 'Sector',
          value: profileState.sector,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateSector(value),
        ),
        const SizedBox(height: 16),

        // Cell
        buildEditableFormField(
          context,
          label: 'Cell',
          value: profileState.cell,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateCell(value),
        ),
        const SizedBox(height: 16),

        // Village
        buildEditableFormField(
          context,
          label: 'Village',
          value: profileState.village,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateVillage(value),
        ),
      ],
    );
  }

  Widget buildEditableFormField(
    BuildContext context, {
    required String label,
    required String value,
    required Function(String) onChanged,
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
            color: Color.fromARGB(255, 57, 58, 58),
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
            color: Color.fromARGB(255, 57, 58, 58),
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