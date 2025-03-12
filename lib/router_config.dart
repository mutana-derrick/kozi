import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/home_screen.dart';
import 'package:kozi/onboarding_screen.dart';
import 'package:kozi/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen - To be implemented')),
        ),
      ),
      GoRoute(
        path: '/admindashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Dashboard - To be implemented')),
        ),
      ),
    ],
  );
});







// Add redirect logic for authenticated users
// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authStateProvider);
  
//   return GoRouter(
//     redirect: (context, state) {
//       final isLoggedIn = authState.isAuthenticated;
//       final isOnboardingDone = /* Check SharedPreferences */;
      
//       if (!isOnboardingDone && state.location != '/onboarding') {
//         return '/onboarding';
//       }
//       if (isLoggedIn && state.location == '/login') {
//         return '/dashboard';
//       }
//       return null;
//     },
//     routes: [/* existing routes */]
//   );
// });