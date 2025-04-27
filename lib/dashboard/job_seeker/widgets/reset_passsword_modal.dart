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

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    // Validate current password
    final currentPasswordError = FormValidation.validateRequired(
        _currentPasswordController.text, 'Current password');
    if (currentPasswordError != null) {
      setState(() => _currentPasswordError = currentPasswordError);
      isValid = false;
    } else {
      setState(() => _currentPasswordError = null);
    }
    
    // Validate new password
    final passwordError = FormValidation.validatePassword(_passwordController.text);
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
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Here you would integrate with your actual password reset API
    // You can use the current password from _currentPasswordController.text
    // and the new password from _passwordController.text

    setState(() {
      _isResetting = false;
    });
    
    if (mounted) {
      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password has been reset successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      
      // Close modal and navigate back to login
      Navigator.of(context).pop();
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

              // Current Password input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _currentPasswordError != null ? ValidationColors.errorRed : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  decoration: InputDecoration(
                    hintText: 'Current Password *',
                    hintStyle: TextStyle(
                      color: _currentPasswordError != null ? ValidationColors.errorRed : Colors.black45,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentPasswordError != null)
                          const Icon(Icons.error, color: ValidationColors.errorRed, size: 20),
                        IconButton(
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: (_) {
                    if (_currentPasswordError != null) {
                      setState(() {
                        _currentPasswordError = null;
                      });
                    }
                  },
                ),
              ),

              if (_currentPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Text(
                    _currentPasswordError!,
                    style: const TextStyle(
                      color: ValidationColors.errorRed,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // New Password input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: _passwordError != null ? ValidationColors.errorRed : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'New Password *',
                    hintStyle: TextStyle(
                      color: _passwordError != null ? ValidationColors.errorRed : Colors.black45,
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
                          const Icon(Icons.error, color: ValidationColors.errorRed, size: 20),
                        IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    // Also clear confirm password error if any, as it depends on this field
                    if (_confirmPasswordError != null) {
                      setState(() {
                        _confirmPasswordError = null;
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
                    color: _confirmPasswordError != null ? ValidationColors.errorRed : Colors.grey.shade300,
                  ),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password *',
                    hintStyle: TextStyle(
                      color: _confirmPasswordError != null ? ValidationColors.errorRed : Colors.black45,
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
                          const Icon(Icons.error, color: ValidationColors.errorRed, size: 20),
                        IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
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
}