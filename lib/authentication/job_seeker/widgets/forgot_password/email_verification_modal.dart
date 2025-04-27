// lib/authentication/job_seeker/widgets/forgot_password/email_verification_modal.dart
import 'package:flutter/material.dart';
import 'package:kozi/authentication/job_seeker/widgets/forgot_password/signup_otp_verification_modal.dart';
import 'package:kozi/utils/form_validation.dart';

class ForgotPasswordModal extends StatefulWidget {
  const ForgotPasswordModal({super.key});

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Validate email
  bool _validateEmail() {
    final emailError = FormValidation.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      return false;
    } else {
      setState(() => _emailError = null);
      return true;
    }
  }

  // Simulate sending the verification code
  Future<void> _sendVerificationCode() async {
    if (!_validateEmail()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Dismiss the current modal
      Navigator.pop(context);

      // Show OTP verification modal
      _showOtpVerificationModal(context, _emailController.text);
    }
  }

  void _showOtpVerificationModal(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SignupOtpVerificationModal(email: email),
    );
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
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

              const SizedBox(height: 10),

              // Title
              const Text(
                "Forgot password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                "Enter your email for the verification process.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // Email input field with validation
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _emailError != null
                        ? ValidationColors.errorRed
                        : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email *',
                    hintStyle: TextStyle(
                      color: _emailError != null
                          ? ValidationColors.errorRed
                          : Colors.black45,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: _emailError != null
                        ? const Icon(Icons.error,
                            color: ValidationColors.errorRed)
                        : null,
                  ),
                  onChanged: (value) {
                    if (_emailError != null) {
                      setState(() => _emailError = null);
                    }
                  },
                ),
              ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _emailError!,
                    style: const TextStyle(
                      color: ValidationColors.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _sendVerificationCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
