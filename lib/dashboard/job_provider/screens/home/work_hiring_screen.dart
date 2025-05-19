import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_provider/models/worker.dart';
import 'package:kozi/dashboard/job_provider/widgets/hire_success_dialog.dart';

final workingModeProvider = StateProvider<String?>((ref) => null);
final needWorkerTimeProvider = StateProvider<String?>((ref) => null);
// New provider for accommodation preference
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
  // Controller for salary range field
  final TextEditingController _salaryRangeController = TextEditingController();

  @override
  void dispose() {
    _salaryRangeController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker Card
              Container(
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
                      child: Image.asset(
                        widget.worker.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.person,
                                  size: 40, color: Colors.grey),
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
                                widget.worker.name,
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
                            widget.worker.specialty,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating stars
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < widget.worker.rating.floor()
                                      ? Icons.star
                                      : (index < widget.worker.rating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                              const SizedBox(width: 10),
                              Text(
                                '5000 Frw/hr',
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
              ),

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
                    _buildFormField(
                      hintText: 'Fullname',
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      hintText: 'Contact Number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      hintText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      hintText: 'Your address',
                    ),
                    const SizedBox(height: 16),

                    // Need Worker Time Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'When you need worker',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        value: ref.watch(needWorkerTimeProvider),
                        hint: const Text('When you need worker'),
                        items: const [
                          DropdownMenuItem(value: 'ASAP', child: Text('ASAP')),
                          DropdownMenuItem(
                              value: 'Within a day',
                              child: Text('Within a day')),
                          DropdownMenuItem(
                              value: 'Next week', child: Text('Next week')),
                          DropdownMenuItem(
                              value: 'Next month', child: Text('Next month')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            ref.read(needWorkerTimeProvider.notifier).state =
                                value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select when you need the worker';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Working Mode Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Working mode',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        value: ref.watch(workingModeProvider),
                        hint: const Text('Select working mode'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Part-time', child: Text('Part-time')),
                          DropdownMenuItem(
                              value: 'Full-time', child: Text('Full-time')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            ref.read(workingModeProvider.notifier).state =
                                value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a working mode';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NEW: Accommodation Preference Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Accommodation preference',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        value: ref.watch(accommodationPreferenceProvider),
                        hint: const Text('Select accommodation preference'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Stay in', child: Text('Stay in')),
                          DropdownMenuItem(
                              value: 'Stay out', child: Text('Stay out')),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            ref
                                .read(accommodationPreferenceProvider.notifier)
                                .state = value;
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select accommodation preference';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NEW: Salary Range Field
                    _buildFormField(
                      hintText: 'Salary range (e.g., 5000-10000 Frw)',
                      controller: _salaryRangeController,
                      keyboardType: TextInputType.text,
                    ),

                    const SizedBox(height: 16),

                    // Job Description Field
                    _buildFormField(
                      hintText: 'Job description',
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.pink),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.pink),
                                      ),
                                    );
                                  },
                                );

                                // Simulate API call with a delay
                                Future.delayed(const Duration(seconds: 2), () {
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
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
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

  Widget _buildFormField({
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    TextEditingController? controller,
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
}
