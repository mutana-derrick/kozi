import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../authentication/job_seeker/providers/auth_provider.dart';

// Auth guard for routes that require authentication
class AuthGuard extends ConsumerWidget {
  final Widget child;
  final String redirectRoute;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectRoute = '/seekerlogin',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Check if user is authenticated
    if (!authState.isAuthenticated) {
      // Redirect to login after a short delay to allow the widget to build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(redirectRoute);
      });
      
      // Show a loading indicator while redirecting
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User is authenticated, show the protected content
    return child;
  }
}