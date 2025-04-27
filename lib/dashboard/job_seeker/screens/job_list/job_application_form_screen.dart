import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';

// Step provider to track current application step
final applicationStepProvider = StateProvider<int>((ref) => 1);

// Providers to track work history and education entries
final workHistoryEntriesProvider =
    StateProvider<List<WorkHistoryEntry>>((ref) => [WorkHistoryEntry()]);
final educationEntriesProvider =
    StateProvider<List<EducationEntry>>((ref) => [EducationEntry()]);

// Models for work history and education entries
class WorkHistoryEntry {
  String companyName = '';
  String titleAndExperience = '';
}

class EducationEntry {
  String schoolNameAndLevel = '';
  String field = '';
}

// Provider for application loading state
final applicationSubmitLoadingProvider = StateProvider<bool>((ref) => false);
// Provider for application error message
final applicationErrorMessageProvider = StateProvider<String?>((ref) => null);

class JobApplicationFormScreen extends ConsumerWidget {
  final String jobId;

  const JobApplicationFormScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(applicationStepProvider);
    // ignore: unused_local_variable
    final isSubmitting = ref.watch(applicationSubmitLoadingProvider);
    final errorMessage = ref.watch(applicationErrorMessageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.center,
              colors: [
                Color(0xFFF8BADC),
                Color.fromARGB(255, 250, 240, 245),
              ],
            ),
          ),
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (currentStep > 1) {
                          ref.read(applicationStepProvider.notifier).state--;
                        } else {
                          context.pop();
                        }
                      },
                    ),
                    const Spacer(),
                    const Text(
                      'Job Application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Progress indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Step $currentStep/2',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: currentStep / 2,
                      backgroundColor: Colors.pink[100],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.pink[400]!,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),

              // Error message if any
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // Form content based on current step
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: currentStep == 1
                      ? _buildPersonalInfoForm(context, ref)
                      : _buildExperienceForm(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                color: Colors.pink[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Name field
            TextField(
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Email field
            TextField(
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Phone field
            TextField(
              decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Gender selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio(
                      value: 'Male',
                      groupValue: 'Male',
                      activeColor: Colors.pink[400],
                      onChanged: (value) {},
                    ),
                    const Text('Male'),
                    const SizedBox(width: 16),
                    Radio(
                      value: 'Female',
                      groupValue: 'Male',
                      activeColor: Colors.pink[400],
                      onChanged: (value) {},
                    ),
                    const Text('Female'),
                    const SizedBox(width: 16),
                    Radio(
                      value: 'Others',
                      groupValue: 'Male',
                      activeColor: Colors.pink[400],
                      onChanged: (value) {},
                    ),
                    const Text('Others'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Next button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ref.read(applicationStepProvider.notifier).state = 2;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceForm(BuildContext context, WidgetRef ref) {
    final workHistoryEntries = ref.watch(workHistoryEntriesProvider);
    final educationEntries = ref.watch(educationEntriesProvider);
    final isSubmitting = ref.watch(applicationSubmitLoadingProvider);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience',
                  style: TextStyle(
                    color: Colors.pink[400],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Work History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.pink[400]),
                  onPressed: () {
                    ref.read(workHistoryEntriesProvider.notifier).state = [
                      ...workHistoryEntries,
                      WorkHistoryEntry()
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic Work History Fields
            ...workHistoryEntries.asMap().entries.map((entry) {
              final index = entry.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const Divider(height: 32),
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Work History ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (index > 0)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                final newEntries = List<WorkHistoryEntry>.from(
                                    workHistoryEntries);
                                newEntries.removeAt(index);
                                ref
                                    .read(workHistoryEntriesProvider.notifier)
                                    .state = newEntries;
                              },
                            ),
                        ],
                      ),
                    ),
                  // Company name field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Company Name',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final newEntries =
                          List<WorkHistoryEntry>.from(workHistoryEntries);
                      newEntries[index].companyName = value;
                      ref.read(workHistoryEntriesProvider.notifier).state =
                          newEntries;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Title field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Title and Experience',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final newEntries =
                          List<WorkHistoryEntry>.from(workHistoryEntries);
                      newEntries[index].titleAndExperience = value;
                      ref.read(workHistoryEntriesProvider.notifier).state =
                          newEntries;
                    },
                  ),
                ],
              );
            }).toList(),

            const SizedBox(height: 24),

            // Education Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education',
                  style: TextStyle(
                    color: Colors.pink[400],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.pink[400]),
                  onPressed: () {
                    ref.read(educationEntriesProvider.notifier).state = [
                      ...educationEntries,
                      EducationEntry()
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dynamic Education Fields
            ...educationEntries.asMap().entries.map((entry) {
              final index = entry.key;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) const Divider(height: 32),
                  if (index > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Education ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (index > 0)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () {
                                final newEntries =
                                    List<EducationEntry>.from(educationEntries);
                                newEntries.removeAt(index);
                                ref
                                    .read(educationEntriesProvider.notifier)
                                    .state = newEntries;
                              },
                            ),
                        ],
                      ),
                    ),
                  // School field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Qualifications',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final newEntries =
                          List<EducationEntry>.from(educationEntries);
                      newEntries[index].schoolNameAndLevel = value;
                      ref.read(educationEntriesProvider.notifier).state =
                          newEntries;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Field of study
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Field',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      final newEntries =
                          List<EducationEntry>.from(educationEntries);
                      newEntries[index].field = value;
                      ref.read(educationEntriesProvider.notifier).state =
                          newEntries;
                    },
                  ),
                ],
              );
            }).toList(),

            const SizedBox(height: 16),
            // CV upload button
            InkWell(
              onTap: () async {
                // Add CV upload functionality here using file_picker
                /* Example:
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  String filePath = result.files.single.path!;
                  // Store the file path in a provider
                }
                */
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Please upload a PDF of your CV',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Icon(Icons.file_upload_outlined, color: Colors.pink[400]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () => _submitApplication(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.pink[200],
                ),
                child: isSubmitting
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
                        'Submit Application',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to handle application submission with API integration
  Future<void> _submitApplication(BuildContext context, WidgetRef ref) async {
    // Clear any previous error messages
    ref.read(applicationErrorMessageProvider.notifier).state = null;

    // Set loading state to true
    ref.read(applicationSubmitLoadingProvider.notifier).state = true;

    try {
      // Get API service from provider
      final apiService = ref.read(apiServiceProvider);

      // Call the API to apply for the job
      final result = await apiService.applyForJob(jobId);

      // Set loading state to false
      ref.read(applicationSubmitLoadingProvider.notifier).state = false;

      if (result['success']) {
        // Show success dialog
        if (context.mounted) {
          _showApplicationSubmittedDialog(context);
        }
      } else {
        // Show error message
        ref.read(applicationErrorMessageProvider.notifier).state =
            result['message'] ?? 'Failed to submit application';
      }
    } catch (e) {
      // Set loading state to false
      ref.read(applicationSubmitLoadingProvider.notifier).state = false;

      // Show error message
      ref.read(applicationErrorMessageProvider.notifier).state =
          'An error occurred: $e';
    }
  }

  void _showApplicationSubmittedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Application Submitted"),
          content: const Text(
              "Your application has been submitted successfully. We will review it and get back to you soon."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate back to home or jobs list
                context.go('/jobs');
              },
            ),
          ],
        );
      },
    );
  }
}
