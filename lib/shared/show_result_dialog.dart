import 'package:flutter/material.dart';

Future<void> showResultDialog({
  required BuildContext context,
  required String message,
  bool isSuccess = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSuccess
                  ? [
                      Colors.green.shade50,
                      Colors.white,
                    ]
                  : [
                      Colors.red.shade50,
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container with animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: (isSuccess ? Colors.green : Colors.red)
                          .withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 48,
                  color:
                      isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                isSuccess ? 'Success!' : 'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color:
                      isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),

              const SizedBox(height: 12),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
