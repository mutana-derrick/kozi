// lib/dashboard/job_seeker/widgets/reset_passsword_modal.dart
import 'package:flutter/material.dart';
import 'package:kozi/utils/form_validation.dart';

class ResetPasswordModal extends StatefulWidget {
  const ResetPasswordModal({super.key});

  @override
  State<ResetPasswordModal> createState() => _ResetPasswordModalState();
}

class _ResetPasswordModalState extends State<ResetPasswordModal> {
  // Added current password controller
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  // Added obscure state for current password
  bool _obscureCurrentPassword = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isResetting = false;
  
  // Added error state for current password
  String? _currentPasswordError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    // Clear all previous errors
    setState(() {
      _currentPasswordError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _generalError = null;
    });
    
    // Validate current password
    if (_currentPasswordController.text.isEmpty) {
      setState(() => _currentPasswordError = 'Current password is required');
      isValid = false;
    } else if (_currentPasswordController.text.length < 6) {
      setState(() => _currentPasswordError = 'Password must be at least 6 characters');
      isValid = false;
    }
    
    // Validate new password
    final passwordError = FormValidation.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      isValid = false;
    }
    
    // Additional password requirements
    if (_passwordController.text.isNotEmpty) {
      // Check if new password is same as current password
      if (_passwordController.text == _currentPasswordController.text) {
        setState(() => _passwordError = 'New password must be different from current password');
        isValid = false;
      }
      
      // Check for password complexity
      bool hasUppercase = _passwordController.text.contains(RegExp(r'[A-Z]'));
      bool hasDigit = _passwordController.text.contains(RegExp(r'[0-9]'));
      bool hasSpecialChar = _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      
      if (!hasUppercase || !hasDigit || !hasSpecialChar) {
        setState(() => _passwordError = 'Password must contain uppercase, number and special character');
        isValid = false;
      }
    }
    
    // Validate confirm password
    final confirmPasswordError = FormValidation.validateConfirmPassword(
        _confirmPasswordController.text, _passwordController.text);
    if (confirmPasswordError != null) {
      setState(() => _confirmPasswordError = confirmPasswordError);
      isValid = false;
    }
    
    return isValid;
  }

  Future<void> _resetPassword() async {
    if (!_validateInputs()) {
      return;
    }
    
    setState(() {
      _isResetting = true;
    });
    
    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Here you would integrate with your actual password reset API
      // For demonstration, we'll simulate a successful response
      
      if (mounted) {
        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password has been reset successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close modal and navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Handle error
      setState(() {
        _generalError = 'An error occurred: $e';
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
              const Text(
                "Enter your current password and create a new password for your account.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),
              
              // General error message if any
              if (_generalError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ValidationColors.errorRedLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: ValidationColors.errorRedBorder,
                    ),
                  ),
                  child: Text(
                    _generalError!,
                    style: const TextStyle(
                      color: ValidationColors.errorRed,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Current Password input field
              _buildPasswordField(
                controller: _currentPasswordController,
                hintText: 'Current Password *',
                obscureText: _obscureCurrentPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureCurrentPassword = !_obscureCurrentPassword;
                  });
                },
                errorText: _currentPasswordError,
                onChanged: (_) {
                  if (_currentPasswordError != null) {
                    setState(() => _currentPasswordError = null);
                  }
                },
              ),

              const SizedBox(height: 16),

              // New Password input field
              _buildPasswordField(
                controller: _passwordController,
                hintText: 'New Password *',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                  // Also clear confirm password error if any
                  if (_confirmPasswordError != null) {
                    setState(() => _confirmPasswordError = null);
                  }
                },
              ),

              // Password strength indicator
              if (_passwordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildPasswordStrengthIndicator(_passwordController.text),
                ),

              const SizedBox(height: 16),

              // Confirm Password input field
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password *',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                errorText: _confirmPasswordError,
                onChanged: (_) {
                  if (_confirmPasswordError != null) {
                    setState(() => _confirmPasswordError = null);
                  }
                },
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
  
  // Helper method to build password fields with visibility toggle
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required Function(String) onChanged,
    String? errorText,
  }) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: hasError ? ValidationColors.errorRed : Colors.grey.shade300,
              width: hasError ? 2.0 : 1.0,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: hasError ? ValidationColors.errorRed : Colors.black45,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasError)
                    const Icon(Icons.error, color: ValidationColors.errorRed, size: 20),
                  IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                ],
              ),
            ),
            onChanged: onChanged,
          ),
        ),
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
  
  // Password strength indicator
  Widget _buildPasswordStrengthIndicator(String password) {
    // Calculate password strength
    double strength = 0.0;
    
    // Basic checks
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    
    // Determine strength level
    String strengthText;
    Color strengthColor;
    
    if (strength < 0.4) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength < 0.8) {
      strengthText = 'Medium';
      strengthColor = Colors.orange;
    } else {
      strengthText = 'Strong';
      strengthColor = Colors.green;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: strength,
          minHeight: 8,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Password Strength: $strengthText',
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}