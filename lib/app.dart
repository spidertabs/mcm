// lib/app.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

class MaternalCareApp extends ConsumerWidget {
  const MaternalCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Catch all Flutter framework errors and print to terminal
        FlutterError.onError = (FlutterErrorDetails details) {
          FlutterError.presentError(details);
          debugPrint('═══════════ FLUTTER ERROR ═══════════');
          debugPrint(details.exceptionAsString());
          debugPrint(details.stack.toString());
          debugPrint('═════════════════════════════════════');
        };

        // Catch all async/non-Flutter errors and print to terminal
        PlatformDispatcher.instance.onError = (error, stack) {
          debugPrint('═══════════ PLATFORM ERROR ══════════');
          debugPrint(error.toString());
          debugPrint(stack.toString());
          debugPrint('═════════════════════════════════════');
          return true;
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}