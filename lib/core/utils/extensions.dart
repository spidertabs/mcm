import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme        => Theme.of(this);
  ColorScheme get colors     => Theme.of(this).colorScheme;
  TextTheme get textTheme    => Theme.of(this).textTheme;
  Size get screenSize        => MediaQuery.of(this).size;
  double get screenWidth     => MediaQuery.of(this).size.width;
  double get screenHeight    => MediaQuery.of(this).size.height;
  bool get isSmallScreen     => screenWidth < 360;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension StringX on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  String get titleCase => split(' ').map((w) => w.capitalised).join(' ');
}
