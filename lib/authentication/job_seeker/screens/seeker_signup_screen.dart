import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/shared/policy_modal.dart';
import '../widgets/otp_verification_popup.dart';
import '../providers/auth_provider.dart';

// Provider for password visibility state
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
// Provider for terms agreement state
final termsAgreementProvider = StateProvider<bool>((ref) => false);

class SeekerSignUpScreen extends ConsumerStatefulWidget {
  const SeekerSignUpScreen({super.key}); 

  @override
  ConsumerState<SeekerSignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SeekerSignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showOtpVerification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationPopup(
        email: _emailController.text,
        onVerified: (otp) {
          // Process the OTP verification
          Navigator.of(context).pop(); // Close the dialog
          _processSignUp(otp);
        },
      ),
    );
  }

  Future<void> _processSignUp(String otp) async {
    // Prepare signup data
    final signupData = {
      'email': _emailController.text,
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'password': _passwordController.text,
      'role_id': 3, // Assuming 3 is for job seekers
      'gender': 'Other', // Default value, can be updated later
      'full_name': '${_firstNameController.text} ${_lastNameController.text}',
      'picture': '', // Can be updated later
      'verifiedEmail': true, // Since we verified with OTP
      'token': otp,
      'verification_code': otp,
    };

    final authState = ref.read(authProvider);
    
    if (authState.isLoading) return;

    // Attempt signup
    final success = await ref.read(authProvider.notifier).signup(signupData);
    
    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      
        // Navigate to login or complete profile
        context.push('/seekerlogin');
      }
    } else {
      // Show error
      setState(() {
        _errorMessage = ref.read(authProvider).errorMessage ?? 'Signup failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the password visibility state
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
    // Watch the terms agreement state
    final hasAgreedToTerms = ref.watch(termsAgreementProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    // Watch auth state for loading
    final authState = ref.watch(authProvider);

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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: screenHeight * 0.04),

                      // Join us text
                      const Text(
                        "Join us to get a job",
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
                        "You can search a Job, apply job and find job in 3 days once you complete your profile",
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
                                return const Icon(Icons.g_mobiledata, size: 24);
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

                      // Email Field
                      Container(
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
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // First Name Field
                      Container(
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
                        child: TextField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            hintText: 'First Name',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Last Name Field
                      Container(
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
                        child: TextField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: 'Last Name',
                            hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Password Field
                      Container(
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
                        child: TextField(
                          controller: _passwordController,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(
                              color: Colors.black45,
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                ref
                                    .read(passwordVisibilityProvider.notifier)
                                    .state = !isPasswordVisible;
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error message if any
                      // Error message if any
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Terms and Conditions Checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: hasAgreedToTerms,
                              onChanged: (value) {
                                ref
                                    .read(termsAgreementProvider.notifier)
                                    .state = value ?? false;
                              },
                              activeColor: Colors.grey,
                              shape: const CircleBorder(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree with the ',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Colors.blue,
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
                        onPressed: hasAgreedToTerms && !authState.isLoading
                            ? () {
                                // Basic validation
                                if (_emailController.text.isEmpty || 
                                    _firstNameController.text.isEmpty ||
                                    _lastNameController.text.isEmpty ||
                                    _passwordController.text.isEmpty) {
                                  setState(() {
                                    _errorMessage = 'All fields are required';
                                  });
                                  return;
                                }
                                
                                // Show OTP verification popup
                                _showOtpVerification();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA60A7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor:
                              const Color(0xFFEA60A7).withOpacity(0.5),
                        ),
                        child: authState.isLoading
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
                          context.push('/seekerlogin');
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
    );
  }
}