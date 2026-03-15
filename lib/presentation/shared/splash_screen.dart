// lib/presentation/shared/splash_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _waitAndNavigate();
  }

  Future<void> _waitAndNavigate() async {
    // Show splash for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));

    // Wait for _restoreSession() inside AuthNotifier to finish
    while (ref.read(authStateProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (!mounted) return;

    final user = ref.read(authStateProvider).currentUser;
    context.go(user != null ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primary,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, size: 80, color: Colors.white),
          const SizedBox(height: 24),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 48),
          const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    ),
  );
}