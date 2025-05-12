import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:kozi/authentication/job_seeker/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordModal extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordModal({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends ConsumerState<ResetPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetting = false;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;

    // Validate password
    final passwordError =
        FormValidation.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    // Validate confirm password
    final confirmPasswordError = FormValidation.validateConfirmPassword(
        _confirmPasswordController.text, _passwordController.text);
    if (confirmPasswordError != null) {
      setState(() => _confirmPasswordError = confirmPasswordError);
      isValid = false;
    } else {
      setState(() => _confirmPasswordError = null);
    }

    return isValid;
  }

  Future<void> _resetPassword() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isResetting = true;
      _errorMessage = null;
    });

    try {
      // Use API service to reset password
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.resetPassword(
          widget.email, _passwordController.text);

      if (result['success']) {
        if (mounted) {
          // Success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Password has been reset successfully! You can now login.'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );

          // Close all modals and navigate to login
          Navigator.of(context).popUntil((route) => route.isFirst);
          context.go('/seekerlogin'); // Navigate to login screen
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to reset password.';
        });
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isResetting = false;
      });
    }
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
                "Reset Password",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                "Create a new password for ${widget.email}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              // New Password input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _passwordError != null
                        ? ValidationColors.errorRed
                        : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'New Password *',
                    hintStyle: TextStyle(
                      color: _passwordError != null
                          ? ValidationColors.errorRed
                          : Colors.black45,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_passwordError != null)
                          const Icon(Icons.error,
                              color: ValidationColors.errorRed),
                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: (_) {
                    if (_passwordError != null) {
                      setState(() {
                        _passwordError = null;
                      });
                    }
                  },
                ),
              ),

              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: ValidationColors.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Confirm Password input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _confirmPasswordError != null
                        ? ValidationColors.errorRed
                        : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password *',
                    hintStyle: TextStyle(
                      color: _confirmPasswordError != null
                          ? ValidationColors.errorRed
                          : Colors.black45,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_confirmPasswordError != null)
                          const Icon(Icons.error,
                              color: ValidationColors.errorRed),
                        IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: (_) {
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
                      });
                    }
                  },
                ),
              ),

              if (_confirmPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _confirmPasswordError!,
                    style: const TextStyle(
                      color: ValidationColors.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ),

              // Error message if any
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ValidationColors.errorRedLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: ValidationColors.errorRedBorder,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: ValidationColors.errorRed,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Reset Password button
              ElevatedButton(
                onPressed: _isResetting ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isResetting
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
                        'Reset Password',
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
