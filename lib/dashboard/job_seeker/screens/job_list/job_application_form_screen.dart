import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:file_picker/file_picker.dart';

// Step provider to track current application step
final applicationStepProvider = StateProvider<int>((ref) => 1);

// Providers to track work history and education entries
final workHistoryEntriesProvider =
    StateProvider<List<WorkHistoryEntry>>((ref) => [WorkHistoryEntry()]);
final educationEntriesProvider =
    StateProvider<List<EducationEntry>>((ref) => [EducationEntry()]);

// Provider for form validation errors - personal info step
final personalInfoErrorsProvider = StateProvider<Map<String, String?>>((ref) => {});

// Provider for form validation errors - experience step
final experienceErrorsProvider = StateProvider<Map<String, String?>>((ref) => {});

// Models for work history and education entries
class WorkHistoryEntry {
  String companyName = '';
  String titleAndExperience = '';
  
  bool get isEmpty => companyName.isEmpty && titleAndExperience.isEmpty;
  bool get isPartiallyFilled => (companyName.isNotEmpty && titleAndExperience.isEmpty) || 
                              (companyName.isEmpty && titleAndExperience.isNotEmpty);
}

class EducationEntry {
  String schoolNameAndLevel = '';
  String field = '';
  
  bool get isEmpty => schoolNameAndLevel.isEmpty && field.isEmpty;
  bool get isPartiallyFilled => (schoolNameAndLevel.isNotEmpty && field.isEmpty) || 
                              (schoolNameAndLevel.isEmpty && field.isNotEmpty);
}

// Provider for application loading state
final applicationSubmitLoadingProvider = StateProvider<bool>((ref) => false);
// Provider for application error message
final applicationErrorMessageProvider = StateProvider<String?>((ref) => null);

// Provider for CV file path
final cvFilePathProvider = StateProvider<String?>((ref) => null);

class JobApplicationFormScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobApplicationFormScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobApplicationFormScreen> createState() => _JobApplicationFormScreenState();
}

class _JobApplicationFormScreenState extends ConsumerState<JobApplicationFormScreen> {
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _experienceFormKey = GlobalKey<FormState>();
  
  // Controllers for personal info step
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'Male'; // Default value

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  // Load user data from profile if available
  Future<void> _loadUserData() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final userId = await apiService.getUserId();
      
      if (userId != null) {
        final result = await apiService.getUserProfile(userId);
        if (result['success'] && result['data'] != null) {
          final userData = result['data'];
          
          // Pre-fill form fields with user data
          setState(() {
            _nameController.text = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['telephone'] ?? '';
            _selectedGender = userData['gender'] ?? 'Male';
          });
        }
      }
    } catch (e) {
      // Silently handle errors - user will need to fill the form manually
      print('Error loading user data: $e');
    }
  }

  // Validate personal information step fields
  bool _validatePersonalInfo() {
    bool isValid = true;
    final errorsMap = <String, String?>{};
    
    // Validate full name
    final nameError = FormValidation.validateRequired(
        _nameController.text, 'Full name');
    if (nameError != null) {
      errorsMap['name'] = nameError;
      isValid = false;
    }
    
    // Validate email
    final emailError = FormValidation.validateEmail(_emailController.text);
    if (emailError != null) {
      errorsMap['email'] = emailError;
      isValid = false;
    }
    
    // Validate phone number
    final phoneError = FormValidation.validatePhone(_phoneController.text);
    if (phoneError != null) {
      errorsMap['phone'] = phoneError;
      isValid = false;
    }
    
    // Update the errors provider
    ref.read(personalInfoErrorsProvider.notifier).state = errorsMap;
    
    return isValid;
  }
  
  // Validate experience step fields
  bool _validateExperience() {
    bool isValid = true;
    final errorsMap = <String, String?>{};
    
    final workHistoryEntries = ref.read(workHistoryEntriesProvider);
    final educationEntries = ref.read(educationEntriesProvider);
    
    // Validate work history (only if there are entries that are partially filled)
    for (int i = 0; i < workHistoryEntries.length; i++) {
      final entry = workHistoryEntries[i];
      // Only validate if entry is partially filled
      if (entry.isPartiallyFilled) {
        if (entry.companyName.isEmpty) {
          errorsMap['workCompany_$i'] = 'Company name is required';
          isValid = false;
        }
        if (entry.titleAndExperience.isEmpty) {
          errorsMap['workTitle_$i'] = 'Title/Experience is required';
          isValid = false;
        }
      }
    }
    
    // Validate education (only if there are entries that are partially filled)
    for (int i = 0; i < educationEntries.length; i++) {
      final entry = educationEntries[i];
      // Only validate if entry is partially filled
      if (entry.isPartiallyFilled) {
        if (entry.schoolNameAndLevel.isEmpty) {
          errorsMap['eduSchool_$i'] = 'School/Level is required';
          isValid = false;
        }
        if (entry.field.isEmpty) {
          errorsMap['eduField_$i'] = 'Field is required';
          isValid = false;
        }
      }
    }
    
    // For CV file requirement (if we want to make it required)
    final cvFilePath = ref.read(cvFilePathProvider);
    if (cvFilePath == null || cvFilePath.isEmpty) {
      errorsMap['cvFile'] = 'Please upload your CV/Resume';
      isValid = false;
    }
    
    // Update the errors provider
    ref.read(experienceErrorsProvider.notifier).state = errorsMap;
    
    return isValid;
  }
  
  void _goToStep(int step) {
    // If moving to step 2, validate step 1 first
    if (step == 2 && ref.read(applicationStepProvider) == 1) {
      if (!_validatePersonalInfo()) {
        return;
      }
    }
    
    ref.read(applicationStepProvider.notifier).state = step;
  }
  
 Future<void> _submitApplication() async {
  // Validate the current step (experience step)
  if (!_validateExperience()) {
    return;
  }
  
  // Set loading state
  ref.read(applicationSubmitLoadingProvider.notifier).state = true;
  // Clear error message
  ref.read(applicationErrorMessageProvider.notifier).state = null;
  
  try {
    // Get API service from provider
    final apiService = ref.read(apiServiceProvider);
    
    // First, apply for the job using the applyForJob method
    final applyResult = await apiService.applyForJob(widget.jobId);
    
    if (!applyResult['success']) {
      // If the job application failed, show error
      ref.read(applicationErrorMessageProvider.notifier).state = 
          applyResult['message'] ?? 'Failed to apply for job';
      ref.read(applicationSubmitLoadingProvider.notifier).state = false;
      return;
    }
    
    // Now prepare application form data
    final applicationData = {
      'job_id': widget.jobId,
      'full_name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'gender': _selectedGender,
      'work_history': ref.read(workHistoryEntriesProvider).map((entry) => {
        'company': entry.companyName,
        'title': entry.titleAndExperience,
      }).toList(),
      'education': ref.read(educationEntriesProvider).map((entry) => {
        'school': entry.schoolNameAndLevel,
        'field': entry.field,
      }).toList(),
      'cv_file': ref.read(cvFilePathProvider),
    };
    
    // Submit the detailed application data
    final result = await apiService.submitJobApplication(widget.jobId, applicationData);
    
    // Reset loading state
    ref.read(applicationSubmitLoadingProvider.notifier).state = false;
    
    if (result['success']) {
      // Show success dialog
      if (mounted) {
        _showApplicationSubmittedDialog();
      }
    } else {
      // If form submission failed but the application was created,
      // still show success but with a warning about incomplete details
      if (applyResult['success']) {
        if (mounted) {
          _showPartialSuccessDialog();
        }
      } else {
        // Show error message
        ref.read(applicationErrorMessageProvider.notifier).state = 
            result['message'] ?? 'Failed to submit application details';
      }
    }
  } catch (e) {
    // Reset loading state
    ref.read(applicationSubmitLoadingProvider.notifier).state = false;
    
    // Show error message
    ref.read(applicationErrorMessageProvider.notifier).state = 
        'An error occurred: $e';
  }
}

void _showPartialSuccessDialog() {
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
            "Your application has been successfully submitted. Your application is still being considered."
        ),
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

  void _showApplicationSubmittedDialog() {
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

  @override
  Widget build(BuildContext context) {
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
                      ? _buildPersonalInfoForm()
                      : _buildExperienceForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    final errors = ref.watch(personalInfoErrorsProvider);

    return Form(
      key: _personalInfoFormKey,
      child: Card(
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
              
              // Name field with validation
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hintText: 'Enter your full name',
                errorText: errors['name'],
                isRequired: true,
                onChanged: (value) {
                  // Clear error on change
                  if (errors['name'] != null) {
                    final currentErrors = Map<String, String?>.from(ref.read(personalInfoErrorsProvider));
                    currentErrors.remove('name');
                    ref.read(personalInfoErrorsProvider.notifier).state = currentErrors;
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Email field with validation
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                errorText: errors['email'],
                isRequired: true,
                onChanged: (value) {
                  // Clear error on change
                  if (errors['email'] != null) {
                    final currentErrors = Map<String, String?>.from(ref.read(personalInfoErrorsProvider));
                    currentErrors.remove('email');
                    ref.read(personalInfoErrorsProvider.notifier).state = currentErrors;
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Phone field with validation
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                errorText: errors['phone'],
                isRequired: true,
                onChanged: (value) {
                  // Clear error on change
                  if (errors['phone'] != null) {
                    final currentErrors = Map<String, String?>.from(ref.read(personalInfoErrorsProvider));
                    currentErrors.remove('phone');
                    ref.read(personalInfoErrorsProvider.notifier).state = currentErrors;
                  }
                },
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
                        groupValue: _selectedGender,
                        activeColor: Colors.pink[400],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value as String;
                          });
                        },
                      ),
                      const Text('Male'),
                      const SizedBox(width: 16),
                      Radio(
                        value: 'Female',
                        groupValue: _selectedGender,
                        activeColor: Colors.pink[400],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value as String;
                          });
                        },
                      ),
                      const Text('Female'),
                      const SizedBox(width: 16),
                      Radio(
                        value: 'Other',
                        groupValue: _selectedGender,
                        activeColor: Colors.pink[400],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value as String;
                          });
                        },
                      ),
                      const Text('Other'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Next button
              Center(
                child: ElevatedButton(
                  onPressed: () => _goToStep(2),
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
      ),
    );
  }

  Widget _buildExperienceForm() {
    final workHistoryEntries = ref.watch(workHistoryEntriesProvider);
    final educationEntries = ref.watch(educationEntriesProvider);
    final isSubmitting = ref.watch(applicationSubmitLoadingProvider);
    final errors = ref.watch(experienceErrorsProvider);
    
    return Form(
      key: _experienceFormKey,
      child: Card(
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
                return _buildWorkHistoryEntry(index, errors);
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
                return _buildEducationEntry(index, errors);
              }).toList(),

              const SizedBox(height: 16),
              
              // CV upload button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'CV/Resume',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 57, 58, 58),
                          ),
                        ),
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: ValidationColors.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectCvFile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: errors['cvFile'] != null
                              ? ValidationColors.errorRed
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ref.watch(cvFilePathProvider) != null
                                ? ref.watch(cvFilePathProvider)!.split('/').last
                                : 'Please upload a PDF of your CV',
                            style: TextStyle(
                              color: errors['cvFile'] != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey[600],
                            ),
                          ),
                          Row(
                            children: [
                              if (errors['cvFile'] != null)
                                const Icon(
                                  Icons.error,
                                  color: ValidationColors.errorRed,
                                  size: 20,
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.file_upload_outlined,
                                color: Colors.pink[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (errors['cvFile'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5, left: 5),
                      child: Text(
                        errors['cvFile']!,
                        style: const TextStyle(
                          color: ValidationColors.errorRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Submit button and Previous button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : () => _goToStep(1),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.pink[400],
                        side: BorderSide(color: Colors.pink[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA60A7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkHistoryEntry(int index, Map<String, String?> errors) {
    final workHistoryEntries = ref.watch(workHistoryEntriesProvider);
    final entry = workHistoryEntries[index];
    
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
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      final newEntries = List<WorkHistoryEntry>.from(
                          workHistoryEntries);
                      newEntries.removeAt(index);
                      ref
                          .read(workHistoryEntriesProvider.notifier)
                          .state = newEntries;
                      
                      // Remove any errors for this entry
                      final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
                      currentErrors.remove('workCompany_$index');
                      currentErrors.remove('workTitle_$index');
                      ref.read(experienceErrorsProvider.notifier).state = currentErrors;
                    },
                  ),
              ],
            ),
          ),
        
        // Company name field
        _buildTextField(
          initialValue: entry.companyName,
          label: 'Company Name',
          hintText: 'Enter company name',
          errorText: errors['workCompany_$index'],
          onChanged: (value) {
            final newEntries = List<WorkHistoryEntry>.from(workHistoryEntries);
            newEntries[index].companyName = value;
            ref.read(workHistoryEntriesProvider.notifier).state = newEntries;
            
            // Clear error on change
            if (errors['workCompany_$index'] != null) {
              final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
              currentErrors.remove('workCompany_$index');
              ref.read(experienceErrorsProvider.notifier).state = currentErrors;
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Title and experience field
        _buildTextField(
          initialValue: entry.titleAndExperience,
          label: 'Title and Experience',
          hintText: 'Enter your title and experience',
          errorText: errors['workTitle_$index'],
          onChanged: (value) {
            final newEntries = List<WorkHistoryEntry>.from(workHistoryEntries);
            newEntries[index].titleAndExperience = value;
            ref.read(workHistoryEntriesProvider.notifier).state = newEntries;
            
            // Clear error on change
            if (errors['workTitle_$index'] != null) {
              final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
              currentErrors.remove('workTitle_$index');
              ref.read(experienceErrorsProvider.notifier).state = currentErrors;
            }
          },
        ),
      ],
    );
  }

  Widget _buildEducationEntry(int index, Map<String, String?> errors) {
    final educationEntries = ref.watch(educationEntriesProvider);
    final entry = educationEntries[index];
    
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
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      final newEntries = List<EducationEntry>.from(educationEntries);
                      newEntries.removeAt(index);
                      ref.read(educationEntriesProvider.notifier).state = newEntries;
                      
                      // Remove any errors for this entry
                      final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
                      currentErrors.remove('eduSchool_$index');
                      currentErrors.remove('eduField_$index');
                      ref.read(experienceErrorsProvider.notifier).state = currentErrors;
                    },
                  ),
              ],
            ),
          ),
        
        // School name and level field
        _buildTextField(
          initialValue: entry.schoolNameAndLevel,
          label: 'Qualifications',
          hintText: 'Enter your qualifications',
          errorText: errors['eduSchool_$index'],
          onChanged: (value) {
            final newEntries = List<EducationEntry>.from(educationEntries);
            newEntries[index].schoolNameAndLevel = value;
            ref.read(educationEntriesProvider.notifier).state = newEntries;
            
            // Clear error on change
            if (errors['eduSchool_$index'] != null) {
              final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
              currentErrors.remove('eduSchool_$index');
              ref.read(experienceErrorsProvider.notifier).state = currentErrors;
            }
          },
        ),
        const SizedBox(height: 16),
        
        // Field of study
        _buildTextField(
          initialValue: entry.field,
          label: 'Field',
          hintText: 'Enter your field of study',
          errorText: errors['eduField_$index'],
          onChanged: (value) {
            final newEntries = List<EducationEntry>.from(educationEntries);
            newEntries[index].field = value;
            ref.read(educationEntriesProvider.notifier).state = newEntries;
            
            // Clear error on change
            if (errors['eduField_$index'] != null) {
              final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
              currentErrors.remove('eduField_$index');
              ref.read(experienceErrorsProvider.notifier).state = currentErrors;
            }
          },
        ),
      ],
    );
  }

  // Helper to build text fields with validation display
  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool isRequired = false,
    required Function(String) onChanged,
  }) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 57, 58, 58),
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
        const SizedBox(height: 8),
        
        // Text field with error styling
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: hasError ? ValidationColors.errorRed : Colors.grey[600],
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? ValidationColors.errorRed : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? ValidationColors.errorRed : Colors.grey[300]!,
                width: hasError ? 2.0 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? ValidationColors.errorRed : const Color(0xFFEA60A7),
                width: 2,
              ),
            ),
            suffixIcon: hasError 
              ? const Icon(Icons.error, color: ValidationColors.errorRed)
              : null,
          ),
          onChanged: onChanged,
        ),
        
        // Error message if any
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
  
  // Method to select CV file
  Future<void> _selectCvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      
      if (result != null) {
        final path = result.files.single.path!;
        ref.read(cvFilePathProvider.notifier).state = path;
        
        // Clear error if exists
        final currentErrors = Map<String, String?>.from(ref.read(experienceErrorsProvider));
        if (currentErrors['cvFile'] != null) {
          currentErrors.remove('cvFile');
          ref.read(experienceErrorsProvider.notifier).state = currentErrors;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }
}