import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HireSuccessDialog extends StatelessWidget {
  const HireSuccessDialog({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon in a circle
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8F3), // Light mint color
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.thumb_up,
                  color: Color(0xFFEE6CA4), // Pink color
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Thank you text
            const Text(
              'Thank You !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            
            // Success message
            const Text(
              'Your hiring is Successful',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            
            // Additional info text
            const Text(
              'Thank you for hiring through Kozi Rwanda!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const Text(
              'Our team is processing your request, and we will get back to you within 3-5 working days.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const Text(
              'Stay tuned for updates!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 20),
            
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close both this dialog and the hire form screen
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to worker listing
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE6CA4), // Pink button
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}