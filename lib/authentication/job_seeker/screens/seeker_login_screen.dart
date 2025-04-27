// lib/authentication/job_seeker/screens/seeker_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/utils/form_validation.dart'; 
import '../providers/auth_provider.dart';
import '../widgets/forgot_password/email_verification_modal.dart';

// Provider for password visibility state
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class SeekerLoginScreen extends ConsumerStatefulWidget {
  const SeekerLoginScreen({super.key});

  @override
  ConsumerState<SeekerLoginScreen> createState() => _SeekerLoginScreenState();
}

class _SeekerLoginScreenState extends ConsumerState<SeekerLoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ignore: unused_field
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    // Validate password
    final passwordError =
        FormValidation.validateRequired(_passwordController.text, 'Password');
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    return isValid;
  }

  Future<void> _handleLogin() async {
    // Validate inputs first
    if (!_validateFields()) {
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Use the auth provider to login
    final success = await ref.read(authProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

    if (success) {
      // Navigate to setup profile or dashboard based on your app flow
      context.go('/seekersetupprofile');
    } else {
      // Show error from auth state
      final authState = ref.read(authProvider);
      setState(() {
        _errorMessage = authState.errorMessage ?? 'Login failed';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the password visibility state
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);
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
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: screenHeight * 0.05),

                        // Welcome back text
                        const Center(
                          child: Text(
                            "Welcome back to Kozi",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Subtitle text
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              "Complete your profile and uplifting your chance to be hired as soon as possible, it's just take a blink!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Google Login Button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                                "Login with Google",
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
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            padding: const EdgeInsets.only(
                                top: 5, left: 25, right: 20),
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        SizedBox(height: screenHeight * 0.02),

                        // Password Field with validation
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
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
                            padding: const EdgeInsets.only(
                                top: 5, left: 25, right: 20),
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: ValidationColors.errorRed,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        // Error message if any
                        if (_errorMessage != null)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.all(8),
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

                        SizedBox(height: screenHeight * 0.03),

                        // Login Button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed:
                                authState.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA60A7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
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
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Forgot password
                        GestureDetector(
                          onTap: () {
                            // Show the forgot password modal
                            _showForgotPasswordModal(context);
                          },
                          child: const Center(
                            child: Text(
                              "Forgot password ?",
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.02),

                        // Don't have an account
                        GestureDetector(
                          onTap: () {
                            context.push('/seekersignup');
                          },
                          child: const Center(
                            child: Text(
                              "Don't have an account? Join us",
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),
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

  // Function to show the forgot password modal
  void _showForgotPasswordModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ForgotPasswordModal(),
    );
  }
}