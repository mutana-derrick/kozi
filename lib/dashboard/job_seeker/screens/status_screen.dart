import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_bottom_navbar.dart';
import 'package:kozi/dashboard/job_seeker/widgets/custom_header.dart';

class StatusScreen extends ConsumerWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Container(
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
              const CustomHeader(title: 'Status'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Start your journey with us! Your application status',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProgressBar(),
                        const SizedBox(height: 24),
                        _buildStepItem(
                          percentage: '36%',
                          step: 'Step 1: Initial Sign-up',
                          description: 'Sign up and create your profile.',
                          prescriptionCount: 1,
                          isCompleted: true,
                        ),
                        const SizedBox(height: 16),
                        _buildStepItem(
                          percentage: '66%',
                          step: 'Step 2: Complete \n Your Profile:',
                          description:
                              'Provide accurate information to enhance your job opportunities',
                          prescriptionCount: 1,
                          isCompleted: true,
                        ),
                        const SizedBox(height: 16),
                        _buildStepItem(
                          percentage: '100%',
                          step: 'Step 3: Get Recruited:',
                          description:
                              'You are now part of our team and ready to begin your new role.',
                          prescriptionCount: 1,
                          isCompleted: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior:
          Clip.hardEdge, // Ensures content inside the container is clipped
      child: Row(
        children: [
          Expanded(
            flex: 36,
            child: Container(
              color: const Color(0xFFF8BADC).withOpacity(0.7),
              alignment: Alignment.center,
              child: const Text(
                '36%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 30,
            child: Container(
              color: const Color(0xFFF8BADC),
              alignment: Alignment.center,
              child: const Text(
                '66%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 34,
            child: Container(
              color: const Color(0xFFEC407A),
              alignment: Alignment.center,
              child: const Text(
                '100%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String percentage,
    required String step,
    required String description,
    required int prescriptionCount,
    required bool isCompleted,
  }) {
    return _ExpandableStepItem(
      percentage: percentage,
      step: step,
      description: description,
      prescriptionCount: prescriptionCount,
      isCompleted: isCompleted,
    );
  }
}

class _ExpandableStepItem extends StatefulWidget {
  final String percentage;
  final String step;
  final String description;
  final int prescriptionCount;
  final bool isCompleted;

  const _ExpandableStepItem({
    required this.percentage,
    required this.step,
    required this.description,
    required this.prescriptionCount,
    required this.isCompleted,
  });

  @override
  State<_ExpandableStepItem> createState() => _ExpandableStepItemState();
}

class _ExpandableStepItemState extends State<_ExpandableStepItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.percentage == '36%'
                      ? const Color(0xFFF8BADC).withOpacity(0.7)
                      : widget.percentage == '66%'
                          ? const Color(0xFFF8BADC)
                          : const Color(0xFFEC407A),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.percentage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.step,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.prescriptionCount} Prescription',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
