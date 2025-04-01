import 'package:flutter/material.dart';

class ProfileSetupProgressBar extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTapped;

  const ProfileSetupProgressBar({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1}/3',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentStep + 1) / 3,
            backgroundColor: Colors.pink[100],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFEA60A7),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}