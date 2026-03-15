// lib/main.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'app.dart';
import 'core/storage/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Web: IndexedDB-backed SQLite
    databaseFactory = databaseFactoryFfiWeb;
  } else if (!Platform.isAndroid && !Platform.isIOS) {
    // Linux / Windows / macOS desktop only: use sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // Android & iOS: sqflite works natively — no factory override needed

  await DatabaseHelper.instance.init();

  runApp(
    const ProviderScope(
      child: MaternalCareApp(),
    ),
  );
}