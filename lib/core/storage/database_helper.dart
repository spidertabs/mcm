// lib/core/storage/database_helper.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'seed_data.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  static const String _dbName = 'maternal_care.db';
  static const int _dbVersion = 5;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> init() async {
    await database;
  }

  Future<Database> _initDatabase() async {
    // On Android/iOS use the native sqflite path resolver.
    // On desktop/web databaseFactory is overridden in main.dart (FFI / web).
    final bool useNative = !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS);

    final dbPath = useNative
        ? await getDatabasesPath()
        : await databaseFactory.getDatabasesPath();

    final path = join(dbPath, _dbName);

    return useNative
        ? openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    )
        : databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_createUsersTable);
    await db.execute(_createPatientsTable);
    await db.execute(_createAncVisitsTable);
    await db.execute(_createDeliveryRecordsTable);
    await db.execute(_createPostnatalRecordsTable);
    await db.execute(_createFamilyPlanningTable);
    await db.execute(_createInterventionsTable);
    await SeedData.insertIfEmpty(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN fundal_height REAL');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN malaria_test INTEGER');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN hiv_test INTEGER');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN syphilis_test INTEGER');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN tetanus_dose INTEGER');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN iron_folic_acid INTEGER');
      await db.execute(
          'ALTER TABLE anc_visits ADD COLUMN updated_at TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 4) {
      await db.execute(
          "ALTER TABLE patients ADD COLUMN risk_level TEXT NOT NULL DEFAULT 'low'");
      await db.execute(
          'ALTER TABLE patients ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 5) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN avatar_path TEXT');
    }
  }

  // ── Table DDL ──────────────────────────────────────────────────────────────

  static const String _createUsersTable = '''
    CREATE TABLE users (
      id          TEXT PRIMARY KEY,
      username    TEXT NOT NULL UNIQUE,
      full_name   TEXT NOT NULL,
      password    TEXT NOT NULL,
      role        TEXT NOT NULL,
      is_active   INTEGER NOT NULL DEFAULT 1,
      avatar_path TEXT,
      created_at  TEXT NOT NULL,
      updated_at  TEXT NOT NULL
    )
  ''';

  static const String _createPatientsTable = '''
    CREATE TABLE patients (
      id            TEXT PRIMARY KEY,
      full_name     TEXT NOT NULL,
      date_of_birth TEXT NOT NULL,
      phone         TEXT,
      address       TEXT,
      village       TEXT,
      next_of_kin   TEXT,
      nok_phone     TEXT,
      lmp           TEXT,
      edd           TEXT,
      gravida       INTEGER DEFAULT 0,
      parity        INTEGER DEFAULT 0,
      blood_group   TEXT,
      risk_level    TEXT NOT NULL DEFAULT 'low',
      is_active     INTEGER NOT NULL DEFAULT 1,
      registered_by TEXT NOT NULL,
      created_at    TEXT NOT NULL,
      updated_at    TEXT NOT NULL
    )
  ''';

  static const String _createAncVisitsTable = '''
    CREATE TABLE anc_visits (
      id              TEXT PRIMARY KEY,
      patient_id      TEXT NOT NULL,
      visit_number    INTEGER NOT NULL,
      visit_date      TEXT NOT NULL,
      gestation_weeks INTEGER,
      weight_kg       REAL,
      bp_systolic     INTEGER,
      bp_diastolic    INTEGER,
      fetal_heartrate INTEGER,
      fundal_height   REAL,
      haemoglobin     REAL,
      urinalysis      TEXT,
      malaria_test    INTEGER,
      hiv_test        INTEGER,
      syphilis_test   INTEGER,
      tetanus_dose    INTEGER,
      iron_folic_acid INTEGER,
      next_visit_date TEXT,
      notes           TEXT,
      recorded_by     TEXT NOT NULL,
      created_at      TEXT NOT NULL,
      updated_at      TEXT,
      FOREIGN KEY (patient_id) REFERENCES patients (id)
    )
  ''';

  static const String _createDeliveryRecordsTable = '''
    CREATE TABLE delivery_records (
      id                TEXT PRIMARY KEY,
      patient_id        TEXT NOT NULL,
      delivery_date     TEXT NOT NULL,
      delivery_type     TEXT NOT NULL,
      delivery_outcome  TEXT NOT NULL,
      birth_weight_kg   REAL,
      baby_sex          TEXT,
      apgar_score       INTEGER,
      complications     TEXT,
      blood_loss_ml     REAL,
      placenta_complete INTEGER DEFAULT 1,
      notes             TEXT,
      recorded_by       TEXT NOT NULL,
      created_at        TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES patients (id)
    )
  ''';

  static const String _createPostnatalRecordsTable = '''
    CREATE TABLE postnatal_records (
      id            TEXT PRIMARY KEY,
      patient_id    TEXT NOT NULL,
      visit_date    TEXT NOT NULL,
      visit_number  INTEGER NOT NULL,
      mother_bp_s   INTEGER,
      mother_bp_d   INTEGER,
      mother_temp   REAL,
      lochia        TEXT,
      breastfeeding INTEGER DEFAULT 1,
      baby_weight   REAL,
      baby_temp     REAL,
      notes         TEXT,
      recorded_by   TEXT NOT NULL,
      created_at    TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES patients (id)
    )
  ''';

  static const String _createFamilyPlanningTable = '''
    CREATE TABLE family_planning (
      id            TEXT PRIMARY KEY,
      patient_id    TEXT NOT NULL,
      service_date  TEXT NOT NULL,
      method        TEXT NOT NULL,
      is_new_client INTEGER DEFAULT 1,
      follow_up     TEXT,
      notes         TEXT,
      recorded_by   TEXT NOT NULL,
      created_at    TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES patients (id)
    )
  ''';

  static const String _createInterventionsTable = '''
    CREATE TABLE interventions (
      id                TEXT PRIMARY KEY,
      patient_id        TEXT NOT NULL,
      intervention      TEXT NOT NULL,
      date_time         TEXT NOT NULL,
      reason            TEXT,
      outcome           TEXT,
      referred          INTEGER DEFAULT 0,
      referral_facility TEXT,
      recorded_by       TEXT NOT NULL,
      created_at        TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES patients (id)
    )
  ''';
}