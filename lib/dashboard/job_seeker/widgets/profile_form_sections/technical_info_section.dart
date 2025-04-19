import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/authentication/job_seeker/providers/profile_provider.dart';

class TechnicalInfoSection extends ConsumerWidget {
  const TechnicalInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);

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
            }
          },
        ),
        const SizedBox(height: 16),

        // Category
        buildDropdownField(
          context,
          label: 'Category',
          value: profileState.category.isEmpty
              ? 'Select Category'
              : profileState.category,
          items: const [
            'Basic Worker',
            'Intermediate Worker',
            'Advanced Worker',
            'Specialist'
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(profileProvider.notifier).updateCategory(value);
            }
          },
        ),
        const SizedBox(height: 16),

        // Skills and Capabilities
        buildMultilineFormField(
          context,
          label: 'Skills and Capabilities',
          value: profileState.skills,
          onChanged: (value) =>
              ref.read(profileProvider.notifier).updateSkills(value),
          maxLines: 5,
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
            _showPickImageDialog(context, (filePath) {
              ref.read(profileProvider.notifier).updateNewIdCardPath(filePath);
            });
          },
        ),
        const SizedBox(height: 16),

        buildFileUploadField(
          context,
          label: 'Profile Image',
          fileName: profileState.profileImagePath.isEmpty
              ? 'No file chosen'
              : profileState.profileImagePath.split('/').last,
          onTap: () {
            _showPickImageDialog(context, (filePath) {
              ref
                  .read(profileProvider.notifier)
                  .updateProfileImagePath(filePath);
            });
          },
        ),
        const SizedBox(height: 16),

        buildFileUploadField(
          context,
          label: 'CV/Resume',
          fileName: profileState.cvPath.isEmpty
              ? 'No file chosen'
              : profileState.cvPath.split('/').last,
          onTap: () {
            _showPickFileDialog(context, (filePath) {
              ref.read(profileProvider.notifier).updateCvPath(filePath);
            });
          },
        ),
      ],
    );
  }

  void _showPickImageDialog(BuildContext context, Function(String) onPicked) {
    // In a real app, this would use image_picker to select from gallery or camera
    // For this demo, we're simulating the file selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image'),
        content: const Text('Choose an image source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPicked('/path/to/selected_image.jpg');
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPicked('/path/to/camera_image.jpg');
            },
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }

  void _showPickFileDialog(BuildContext context, Function(String) onPicked) {
    // In a real app, this would use file_picker to select a document
    // For this demo, we're simulating the file selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select File'),
        content: const Text('Choose a document'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onPicked('/path/to/resume.pdf');
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

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
            color: Color.fromARGB(255, 57, 58, 58),
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
