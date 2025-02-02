import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kozi/authentication/login_screen.dart';
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
    ],
  );
});
