import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/shared/policy_modal.dart';
import 'package:kozi/utils/form_validation.dart';
import 'package:kozi/authentication/job_provider/providers/auth_provider.dart';
import '../widgets/otp_verification_popup.dart';

// Provider for password visibility state
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
// Provider for terms agreement state
final termsAgreementProvider = StateProvider<bool>((ref) => false);

class ProviderSignUpScreen extends ConsumerStatefulWidget {
  const ProviderSignUpScreen({super.key});

  @override
  ConsumerState<ProviderSignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<ProviderSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController =
      TextEditingController(); // Added telephone controller

  bool _isLoading = false;
  String? _emailError;
  String? _firstNameError;
  String? _lastNameError;
  String? _passwordError;
  String? _telephoneError; // Added telephone error
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose(); // Dispose telephone controller
    super.dispose();
  }

  // Validate all fields
  bool _validateFields() {
    bool isValid = true;

    // Validate email
    final emailError = FormValidation.validateEmail(_emailController.text);
    if (emailError != null) {
      setState(() => _emailError = emailError);
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    // Validate first name
    final firstNameError = FormValidation.validateRequired(
        _firstNameController.text, 'First name');
    if (firstNameError != null) {
      setState(() => _firstNameError = firstNameError);
      isValid = false;
    } else {
      setState(() => _firstNameError = null);
    }

    // Validate last name
    final lastNameError =
        FormValidation.validateRequired(_lastNameController.text, 'Last name');
    if (lastNameError != null) {
      setState(() => _lastNameError = lastNameError);
      isValid = false;
    } else {
      setState(() => _lastNameError = null);
    }

    // Validate telephone
    final telephoneError =
        FormValidation.validatePhone(_telephoneController.text);
    if (telephoneError != null) {
      setState(() => _telephoneError = telephoneError);
      isValid = false;
    } else {
      setState(() => _telephoneError = null);
    }

    // Validate password
    final passwordError =
        FormValidation.validatePassword(_passwordController.text);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    // Validate terms agreement
    final hasAgreedToTerms = ref.read(termsAgreementProvider);
    if (!hasAgreedToTerms) {
      setState(() => _errorMessage =
          'You must agree to the Terms of Service and Privacy Policy');
      isValid = false;
    } else {
      setState(() => _errorMessage = null);
    }

    return isValid;
  }

  void _showOtpVerification() {
    // Validate all fields first
    if (!_validateFields()) {
      return; // Stop if validation fails
    }

    // Start the signup process which will send OTP
    _initiateSignup();
  }

  Future<void> _initiateSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Prepare signup data to send to API
      final signupData = {
        'email': _emailController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'telephone': _telephoneController.text, // Include telephone
        'password': _passwordController.text,
        'role_id': 2, // Assuming 2 is for job providers
      };

      // Use the API service to register and send OTP
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.signupJobProvider(signupData);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // The API has sent the OTP, now show the verification popup
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => OtpVerificationPopup(
              email: _emailController.text,
              onVerified: (otp) async {
                // Process the OTP verification and return error message if any
                return await _verifyOtp(otp, context);
              },
            ),
          );
        }
      } else {
        // Show error
        setState(() {
          _errorMessage = result['message'] ?? 'Signup failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  Future _verifyOtp(String otp, BuildContext dialogContext) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the API service to verify OTP
      final apiService = ref.read(apiServiceProvider);
      final result = await apiService.verifyOtp(_emailController.text, otp);

      if (result['success']) {
        // OTP verification successful - close the dialog and proceed
        Navigator.of(dialogContext).pop();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created and verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to login
          context.push('/providerlogin');
        }
      } else {
        // OTP verification failed - return error to the OTP dialog
        // Now we're passing the error message to the OTP popup through a callback
        return result['message'] ?? 'OTP verification failed';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Return error message to display in the OTP dialog
      return 'An unexpected error occurred: $e';
    } finally {
      // Always update loading state
      setState(() {
        _isLoading = false;
      });
    }
    return null; // Success - no error
  }

  @override
  Widget build(BuildContext context) {
    // Watch the password visibility state
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    // Watch the terms agreement state
    final hasAgreedToTerms = ref.watch(termsAgreementProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [Color(0xFFF8BADC), Color.fromARGB(255, 250, 240, 245)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: screenHeight * 0.04),

                        // Join us text
                        const Text(
                          "Join us as Job Provider",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Description text
                        const Text(
                          "Find and hire the best workers for your needs with Kozi",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Google Sign Up Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.g_mobiledata,
                                      size: 24);
                                },
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "Sign up with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Email Field with validation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _emailError != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
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
                                fontSize: 16,
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

                        const SizedBox(height: 16),

                        // First Name Field with validation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _firstNameError != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              hintText: 'First Name *',
                              hintStyle: TextStyle(
                                color: _firstNameError != null
                                    ? ValidationColors.errorRed
                                    : Colors.black45,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: _firstNameError != null
                                  ? const Icon(Icons.error,
                                      color: ValidationColors.errorRed)
                                  : null,
                            ),
                            onChanged: (value) {
                              if (_firstNameError != null) {
                                setState(() => _firstNameError = null);
                              }
                            },
                          ),
                        ),

                        if (_firstNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 5),
                            child: Text(
                              _firstNameError!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Last Name Field with validation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _lastNameError != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              hintText: 'Last Name *',
                              hintStyle: TextStyle(
                                color: _lastNameError != null
                                    ? ValidationColors.errorRed
                                    : Colors.black45,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: _lastNameError != null
                                  ? const Icon(Icons.error,
                                      color: ValidationColors.errorRed)
                                  : null,
                            ),
                            onChanged: (value) {
                              if (_lastNameError != null) {
                                setState(() => _lastNameError = null);
                              }
                            },
                          ),
                        ),

                        if (_lastNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 5),
                            child: Text(
                              _lastNameError!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Telephone Field with validation (new)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _telephoneError != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _telephoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Telephone *',
                              hintStyle: TextStyle(
                                color: _telephoneError != null
                                    ? ValidationColors.errorRed
                                    : Colors.black45,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              suffixIcon: _telephoneError != null
                                  ? const Icon(Icons.error,
                                      color: ValidationColors.errorRed)
                                  : null,
                            ),
                            onChanged: (value) {
                              if (_telephoneError != null) {
                                setState(() => _telephoneError = null);
                              }
                            },
                          ),
                        ),

                        if (_telephoneError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 5),
                            child: Text(
                              _telephoneError!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Password Field with validation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _passwordError != null
                                  ? ValidationColors.errorRed
                                  : Colors.grey.shade300,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Password *',
                              hintStyle: TextStyle(
                                color: _passwordError != null
                                    ? ValidationColors.errorRed
                                    : Colors.black45,
                                fontSize: 16,
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
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(passwordVisibilityProvider
                                              .notifier)
                                          .state = !isPasswordVisible;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            onChanged: (value) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
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

                        // Error message if any
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: ValidationColors.errorRedLight,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: ValidationColors.errorRedBorder),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        // Terms and Conditions Checkbox
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _errorMessage != null && !hasAgreedToTerms
                                          ? ValidationColors.errorRed
                                          : Colors.grey,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Checkbox(
                                value: hasAgreedToTerms,
                                onChanged: (value) {
                                  ref
                                      .read(termsAgreementProvider.notifier)
                                      .state = value ?? false;
                                  // Clear error when checked
                                  if (value == true && _errorMessage != null) {
                                    setState(() => _errorMessage = null);
                                  }
                                },
                                activeColor: Colors.grey,
                                checkColor: Colors.white,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree with the ',
                                  style: TextStyle(
                                    color: _errorMessage != null &&
                                            !hasAgreedToTerms
                                        ? ValidationColors.errorRed
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: _errorMessage != null &&
                                                !hasAgreedToTerms
                                            ? ValidationColors.errorRed
                                            : Colors.black87,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                const PrivacyPolicyModal(
                                                    isTermsOfService: true),
                                          );
                                        },
                                    ),
                                    TextSpan(
                                      text: ' & ',
                                      style: TextStyle(
                                        color: _errorMessage != null &&
                                                !hasAgreedToTerms
                                            ? ValidationColors.errorRed
                                            : Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: _errorMessage != null &&
                                                !hasAgreedToTerms
                                            ? ValidationColors.errorRed
                                            : Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) =>
                                                const PrivacyPolicyModal(
                                                    isTermsOfService: false),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Sign Up Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _showOtpVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA60A7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            disabledBackgroundColor: hasAgreedToTerms
                                ? Colors.grey.shade300
                                : const Color(0xFFEA60A7).withOpacity(0.5),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Have an account? ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.push('/providerlogin');
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Color(0xFFEA60A7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
