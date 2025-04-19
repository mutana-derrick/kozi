import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/job_seeker/screens/seeker_setup_profile_screen.dart';
import 'package:kozi/authentication/job_seeker/screens/seeker_signup_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/profile_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/home/provider_dashboard_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_login_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_setup_profile_screen.dart';
import 'package:kozi/authentication/job_provider/screens/provider_signup_screen.dart';
import 'package:kozi/authentication/job_seeker/screens/seeker_login_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/support_screen.dart';
import 'package:kozi/dashboard/job_provider/screens/workers_list_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/job_list/job_application_form_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/job_list/job_application_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/job_list/job_list_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/payment_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/profile/seeker_profile_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/seeker_dashboard_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/seeker_settings_screen.dart';
import 'package:kozi/dashboard/job_seeker/screens/status_screen.dart';
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

// ============================================Job Seeker Routes===================================================
      GoRoute(
        path: '/seekerlogin',
        builder: (context, state) => const SeekerLoginScreen(),
      ),
      GoRoute(
        path: '/seekersignup',
        builder: (context, state) => const SeekerSignUpScreen(),
      ),
      GoRoute(
        path: '/seekersetupprofile',
        builder: (context, state) => const SeekerSetupProfileScreen(),
      ),
      GoRoute(
        path: '/seekerdashboardscreen',
        builder: (context, state) => const SeekerDashboardScreen(),
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobListScreen(),
      ),
      GoRoute(
        path: '/status',
        builder: (context, state) => const StatusScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/seekerprofile',
        builder: (context, state) => const SeekerProfileScreen(),
      ),
      GoRoute(
        path: '/seekersettings',
        builder: (context, state) => const SeekerSettingsScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobApplicationScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/apply/:id/form',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobApplicationFormScreen(jobId: jobId);
        },
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