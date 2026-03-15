import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary   = Color(0xFF6A1B9A); // Deep purple — health/care
  static const Color secondary = Color(0xFFEC407A); // Pink accent
  static const Color accent    = Color(0xFF26C6DA); // Teal highlight

  // Brand containers / light variants
  static const Color primaryContainer   = Color(0xFFE1BEE7); // Light purple
  static const Color secondaryContainer = Color(0xFFFCE4EC); // Light pink
  static const Color primaryLight       = Color(0xFF9C4DCA); // Lighter purple

  // Status
  static const Color success      = Color(0xFF43A047);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning      = Color(0xFFFB8C00);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error        = Color(0xFFE53935);
  static const Color errorLight   = Color(0xFFFFCDD2);
  static const Color info         = Color(0xFF1E88E5);

  // Risk
  static const Color highRisk = Color(0xFFB71C1C); // Dark red for high-risk flags

  // Neutral
  static const Color background    = Color(0xFFF5F5F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint      = Color(0xFFBDBDBD);
  static const Color divider       = Color(0xFFBDBDBD);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Dashboard card colours
  static const Color cardTeal   = Color(0xFF00897B);
  static const Color cardBlue   = Color(0xFF1E88E5);
  static const Color cardPurple = Color(0xFF8E24AA);
  static const Color cardOrange = Color(0xFFFB8C00);

  // Dark mode
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark    = Color(0xFF1E1E1E);
}