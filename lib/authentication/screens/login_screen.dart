import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider for password visibility state
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the password visibility state
    final isPasswordVisible = ref.watch(passwordVisibilityProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo section
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 500,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width * 15,
                      height: MediaQuery.of(context).size.height * 0.9,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Login text
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // Phone number TextField
              TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFDFDFDF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password TextField with visibility toggle
              TextField(
                obscureText: !isPasswordVisible, // Toggle based on state
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFDFDFDF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  // Updated visibility toggle with state
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Toggle password visibility using Riverpod
                      ref.read(passwordVisibilityProvider.notifier).state =
                          !isPasswordVisible;
                    },
                  ),
                ),
              ),

              // Forget Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    //  login  here
                  },
                  child: const Text(
                    'Forget Password ?',
                    style: TextStyle(
                      color: Color(0xFF284290),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Login Button
              ElevatedButton(
                onPressed: () => context.push('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA60A7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
