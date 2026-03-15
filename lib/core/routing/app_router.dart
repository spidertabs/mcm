// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/dashboard/dashboard_screen.dart';
import '../../presentation/patients/patients_screen.dart';
import '../../presentation/anc/anc_screen.dart';
import '../../presentation/delivery/delivery_screen.dart';
import '../../presentation/postnatal/postnatal_screen.dart';
import '../../presentation/family_planning/family_planning_screen.dart';
import '../../presentation/reports/reports_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/shared/splash_screen.dart';
import '../constants/app_routes.dart';
import '../providers/auth_provider.dart';

export '../../presentation/patients/patients_screen.dart' show PatientFormScreen;
export '../../presentation/anc/anc_screen.dart' show AncFormScreen;
export '../../presentation/delivery/delivery_screen.dart' show DeliveryFormScreen;
export '../../presentation/postnatal/postnatal_screen.dart' show PostnatalFormScreen;

final appRouterProvider = Provider<GoRouter>((ref) {
  // ✅ FIX: Use a ValueNotifier so the router is created ONCE
  // but can still refresh when auth state changes
  final authNotifier = ValueNotifier<AuthState>(
    ref.read(authStateProvider),
  );

  // Keep the ValueNotifier in sync with auth state changes
  // without rebuilding the entire GoRouter
  ref.listen<AuthState>(authStateProvider, (_, next) {
    authNotifier.value = next;
  });

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    // ✅ Attach the notifier so redirect re-runs on auth change
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = authNotifier.value;

      // Don't redirect while session is being restored
      if (authState.isLoading) return null;

      final isLoggedIn = authState.currentUser != null;
      final onAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !onAuthPage) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      // Auth & splash
      GoRoute(path: AppRoutes.splash,    builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login,     builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register,  builder: (_, __) => const RegisterScreen()),

      // Dashboard
      GoRoute(path: AppRoutes.dashboard, builder: (_, __) => const DashboardScreen()),

      // Patients
      GoRoute(path: AppRoutes.patients,   builder: (_, __) => const PatientsScreen()),
      GoRoute(path: AppRoutes.patientNew, builder: (_, __) => const PatientFormScreen()),
      GoRoute(
        path: AppRoutes.patientDetail,
        builder: (_, state) =>
            PatientFormScreen(patientId: state.pathParameters['id']),
      ),

      // ANC
      GoRoute(path: AppRoutes.anc,    builder: (_, __) => const AncScreen()),
      GoRoute(path: AppRoutes.ancNew, builder: (_, __) => const AncFormScreen()),

      // Delivery
      GoRoute(path: AppRoutes.delivery,    builder: (_, __) => const DeliveryScreen()),
      GoRoute(path: AppRoutes.deliveryNew, builder: (_, __) => const DeliveryFormScreen()),

      // Postnatal
      GoRoute(path: AppRoutes.postnatal,    builder: (_, __) => const PostnatalScreen()),
      GoRoute(path: AppRoutes.postnatalNew, builder: (_, __) => const PostnatalFormScreen()),

      // Remaining screens
      GoRoute(path: AppRoutes.familyPlanning, builder: (_, __) => const FamilyPlanningScreen()),
      GoRoute(path: AppRoutes.reports,        builder: (_, __) => const ReportsScreen()),
      GoRoute(path: AppRoutes.settings,       builder: (_, __) => const SettingsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );

  // Dispose the notifier when the provider is disposed
  ref.onDispose(() => authNotifier.dispose());

  return router;
});