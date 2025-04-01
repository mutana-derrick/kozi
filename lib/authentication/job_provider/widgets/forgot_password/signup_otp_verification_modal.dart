import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kozi/authentication/job_seeker/widgets/forgot_password/reset_passsword_modal.dart';


class SignupOtpVerificationModal extends StatefulWidget {
  final String email;

  const SignupOtpVerificationModal({
    super.key,
    required this.email,
  });

  @override
  State<SignupOtpVerificationModal> createState() => _OtpVerificationModalState();
}

class _OtpVerificationModalState extends State<SignupOtpVerificationModal> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _timeLeft = 180; // 3 minutes in seconds
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  String _formatTimeLeft() {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  Future<void> _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      setState(() {
        _isVerifying = true;
      });

      // Simulate verification process
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        // Dismiss the current modal
        Navigator.pop(context);

        // Show reset password modal
        _showResetPasswordModal(context);
      }
    } else {
      // Show error message if OTP is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showResetPasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ResetPasswordModal(),
    );
  }

  void _requestNewCode() {
    // Reset timer
    setState(() {
      _timeLeft = 180;
    });
    _startTimer();

    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }

    // Set focus to first field
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }

    // Show a snackbar to confirm
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new verification code has been sent.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close button row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Please enter the verification code sent to ${widget.email}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),

            // OTP input fields
            LayoutBuilder(
              builder: (context, constraints) {
                double fieldWidth = (constraints.maxWidth - 50) / 6;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: fieldWidth,
                      height: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                                color: Color(0xFFEA60A7), width: 2),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }

                          // If all fields are filled, auto-verify
                          if (index == 5 && value.isNotEmpty) {
                            String otp = _controllers.map((controller) => controller.text).join();
                            if (otp.length == 6) {
                              _verifyOtp();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                );
              }
            ),

            const SizedBox(height: 24),

            // Confirm button
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA60A7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Timer text
            Center(
              child: Text(
                'Code expires in: ${_formatTimeLeft()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Request another code - conditionally clickable
            Center(
              child: GestureDetector(
                onTap: _timeLeft <= 0 ? _requestNewCode : null,
                child: Text(
                  'Request another verification code',
                  style: TextStyle(
                    color: _timeLeft <= 0
                        ? const Color(0xFFEA60A7)
                        : Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}