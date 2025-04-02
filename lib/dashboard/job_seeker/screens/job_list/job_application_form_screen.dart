import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';

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

class JobApplicationFormScreen extends ConsumerWidget {
  final String jobId;

  const JobApplicationFormScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(applicationStepProvider);

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
              // onTap: () async {
              //   final result = await FilePicker.platform.pickFiles(
              //     type: FileType.custom,
              //     allowedExtensions: ['pdf'],
              //   );
              //   // Handle file selection
              // },
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
                onPressed: () {
                  // Submit application logic
                  _showApplicationSubmittedDialog(context);
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

  void _showApplicationSubmittedDialog(BuildContext context) {
    showDialog(
      context: context,
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
