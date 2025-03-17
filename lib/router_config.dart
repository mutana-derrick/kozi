import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/dashboard/job_provider/screens/profile_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/provider_dashboard_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_login_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_setup_profile_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_signup_screen.dart';
import 'package:kozi/authentication/job_seeker/screens/seeker_login_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/support_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/workers_list_screen.dart';
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
        path: '/providerlogin',
        builder: (context, state) => const ProviderLoginScreen(),
      ),
      GoRoute(
        path: '/providersignup',
        builder: (context, state) => const ProviderSignUpScreen(),
      ),
      GoRoute(
        path: '/seekerlogin',
        builder: (context, state) => const SeekerLoginScreen(),
      ),
      GoRoute(
        path: '/providersetupprofile',
        builder: (context, state) => const ProviderSetupProfileScreen(),
      ),
      GoRoute(
        path: '/providerdashboardscreen',
        builder: (context, state) => const ProviderDashboardScreen(),
      ),
      GoRoute(
        path: '/workerslistcreen',
        builder: (context, state) => const WorkersListScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
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