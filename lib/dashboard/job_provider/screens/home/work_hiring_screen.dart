import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/widgets/hire_success_dialog.dart';
import 'package:kozi/services/api_service.dart'; // Import API service

final workingModeProvider = StateProvider<String?>((ref) => null);
final needWorkerTimeProvider = StateProvider<String?>((ref) => null);
final accommodationPreferenceProvider = StateProvider<String?>((ref) => null);

class HireWorkerFormScreen extends ConsumerStatefulWidget {
  final Worker worker;

  const HireWorkerFormScreen({
    super.key,
    required this.worker,
  });

  @override
  ConsumerState<HireWorkerFormScreen> createState() =>
      _HireWorkerFormScreenState();
}

class _HireWorkerFormScreenState extends ConsumerState<HireWorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _jobDescriptionController =
      TextEditingController();

  // API service
  final ApiService _apiService = ApiService();

  // Data variables
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _jobProviderData = {};
  Map<String, dynamic> _workerData = {};
  int? _jobProviderId;
  int? _jobSeekerId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Get user email from secure storage
      final userEmail = await _apiService.getUserEmail();

      if (userEmail == null || userEmail.isEmpty) {
        throw Exception('User email not found. Please log in again.');
      }

      // Set the email in the controller
      _emailController.text = userEmail;

      // Get user ID by email
      final userId = await _apiService.getUserIdByEmail(userEmail);

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Get job provider ID
      _jobProviderId = await _apiService.getJobProviderId(int.parse(userId));

      // Get job provider profile data
      _jobProviderData =
          await _apiService.fetchJobProviderProfile(int.parse(userId));

      // Get worker data
      _workerData =
          await _apiService.getWorkerById(widget.worker.id.toString());

      final jobSeekerInfo =
          await _apiService.getJobSeekerByUserId(widget.worker.id.toString());
      _jobSeekerId = int.parse(jobSeekerInfo['job_seeker_id'].toString());

      // Pre-fill form fields with job provider data
      _populateFormFields();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateFormFields() {
    // Extract name parts for provider
    final firstName = _jobProviderData['first_name'] ?? '';
    final lastName = _jobProviderData['last_name'] ?? '';

    // Populate form fields
    _fullnameController.text = '$firstName $lastName'.trim();
    _contactController.text = _jobProviderData['telephone'] ?? '';
    _addressController.text = _jobProviderData['district'] ?? '';
    // Note: Email is already populated from getUserEmail() in _loadData()
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitHireRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          ),
        );
      },
    );

    try {
      // Extract name parts for provider and worker
      final providerNameParts = _fullnameController.text.split(' ');
      final providerFirstName = providerNameParts.first;
      final providerLastName =
          providerNameParts.length > 1 ? providerNameParts.last : '';

      final workerNameParts = widget.worker.name.split(' ');
      final seekerFirstName = workerNameParts.first;
      final seekerLastName =
          workerNameParts.length > 1 ? workerNameParts.last : '';

      // Submit hire request
      final result = await _apiService.hireWorker(
        jobSeekerId: _jobSeekerId.toString(),
        jobProviderId: _jobProviderId.toString(),
        providerFirstName: providerFirstName,
        providerLastName: providerLastName,
        seekerFirstName: seekerFirstName,
        seekerLastName: seekerLastName,
        whenNeedWorker: ref.read(needWorkerTimeProvider) ?? '',
        workingMode: ref.read(workingModeProvider) ?? '',
        accommodationPreference:
            ref.read(accommodationPreferenceProvider) ?? '',
        jobDescription: _jobDescriptionController.text,
      );

      // Handle already hired case
      if (result['status'] == 'conflict') {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const HireSuccessDialog();
        },
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F7), // Light pink background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                const Icon(Icons.arrow_back_ios, size: 16, color: Colors.black),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Worker Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker Card
                        _buildWorkerCard(),

                        const SizedBox(height: 24),
                        const Text(
                          'Fill this form to hire with us:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Hire Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Read-only fields
                              _buildReadOnlyFormField(
                                hintText: 'Fullname',
                                controller: _fullnameController,
                              ),
                              const SizedBox(height: 16),
                              _buildReadOnlyFormField(
                                hintText: 'Contact Number',
                                controller: _contactController,
                              ),
                              const SizedBox(height: 16),
                              _buildReadOnlyFormField(
                                hintText: 'Email address',
                                controller: _emailController,
                              ),
                              const SizedBox(height: 16),
                              _buildReadOnlyFormField(
                                hintText: 'Your address',
                                controller: _addressController,
                              ),
                              const SizedBox(height: 16),

                              // Need Worker Time Dropdown
                              _buildDropdownField(
                                hintText: 'When you need worker',
                                provider: needWorkerTimeProvider,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'ASAP', child: Text('ASAP')),
                                  DropdownMenuItem(
                                      value: 'Within a day',
                                      child: Text('Within a day')),
                                  DropdownMenuItem(
                                      value: 'Next week',
                                      child: Text('Next week')),
                                  DropdownMenuItem(
                                      value: 'Next month',
                                      child: Text('Next month')),
                                ],
                                validationMessage:
                                    'Please select when you need the worker',
                              ),

                              const SizedBox(height: 16),

                              // Working Mode Dropdown
                              _buildDropdownField(
                                hintText: 'Working mode',
                                provider: workingModeProvider,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Part-time',
                                      child: Text('Part-time')),
                                  DropdownMenuItem(
                                      value: 'Full-time',
                                      child: Text('Full-time')),
                                ],
                                validationMessage:
                                    'Please select a working mode',
                              ),

                              const SizedBox(height: 16),

                              // Accommodation Preference Dropdown
                              _buildDropdownField(
                                hintText: 'Accommodation preference',
                                provider: accommodationPreferenceProvider,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Stay in', child: Text('Stay in')),
                                  DropdownMenuItem(
                                      value: 'Stay out',
                                      child: Text('Stay out')),
                                ],
                                validationMessage:
                                    'Please select accommodation preference',
                              ),

                              const SizedBox(height: 16),

                              // Job Description Field
                              _buildFormField(
                                hintText: 'Job description',
                                controller: _jobDescriptionController,
                                maxLines: 5,
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        side: const BorderSide(
                                            color: Colors.pink),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: Colors.pink,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _submitHireRequest,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWorkerCard() {
    // Extract worker's hourly rate from API data
    final hourlyRate = _workerData.isNotEmpty && _workerData['salary'] != null
        ? _workerData['salary'].toString()
        : widget.worker.hourlyRate?.toString() ?? '50000';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Worker image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _workerData.isNotEmpty && _workerData['profile_image'] != null
                  ? _workerData['profile_image']
                  : widget.worker.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Worker details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _workerData.isNotEmpty
                          ? "${_workerData['first_name'] ?? ''} ${_workerData['last_name'] ?? ''}"
                          : widget.worker.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: Colors.pink,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _workerData.isNotEmpty && _workerData['category'] != null
                      ? _workerData['category']
                      : widget.worker.specialty,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Rating stars and hourly rate
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final rating = _workerData.isNotEmpty &&
                              _workerData['rating'] != null
                          ? double.tryParse(_workerData['rating'].toString()) ??
                              widget.worker.rating
                          : widget.worker.rating;

                      return Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index < rating
                                ? Icons.star_half
                                : Icons.star_border),
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    const SizedBox(width: 10),
                    Text(
                      hourlyRate,
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New widget for read-only form fields
  Widget _buildReadOnlyFormField({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.pink),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hintText,
    required StateProvider<String?> provider,
    required List<DropdownMenuItem<String>> items,
    required String validationMessage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black),
        ),
        value: ref.watch(provider),
        hint: Text(hintText),
        items: items,
        onChanged: (String? value) {
          if (value != null) {
            ref.read(provider.notifier).state = value;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }
}
