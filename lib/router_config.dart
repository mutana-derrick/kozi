import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/admin/screens/dashboard_screen.dart';
import 'package:kozi/authentication/screens/login_screen.dart';
import 'package:kozi/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    restorationScopeId: 'router',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/admindashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '//job-seeker',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/providers',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/jobs',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
      GoRoute(
        path: '/agents',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
      ),
    ],
  );
});
