// lib/core/storage/seed_data.dart
// Call SeedData.insertIfEmpty(db) inside DatabaseHelper._onCreate()
// It inserts a demo health-worker account + 100 patients with ANC visits,
// deliveries, postnatal records and family-planning records.

import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';

class SeedData {
  SeedData._();

  static const String _recordedBy = 'seed-hw-001';
  static const String _now = '2026-03-14T10:00:00.000';

  static Future<void> insertIfEmpty(Database db) async {
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM patients'));
    if (count != null && count > 0) return; // already seeded

    await _insertUsers(db);
    await _insertPatients(db);
    await _insertAncVisits(db);
    await _insertDeliveries(db);
    await _insertPostnatal(db);
    await _insertFamilyPlanning(db);
  }

  // ── Users ──────────────────────────────────────────────────────────────────
  static Future<void> _insertUsers(Database db) async {
    // Hash is generated at runtime so it's always valid
    // Both seed accounts use password: demo1234
    final hash = BCrypt.hashpw('demo1234', BCrypt.gensalt());
    final users = [
      {
        'id': _recordedBy,
        'username': 'sarahmabike',
        'full_name': 'Sarah Mabike',
        'password': hash,
        'role': 'administrator',
        'is_active': 1,
        'created_at': _now,
        'updated_at': _now,
      },
      {
        'id': 'seed-hw-002',
        'username': 'graceopio',
        'full_name': 'Grace Opio',
        'password': hash,
        'role': 'healthWorker',
        'is_active': 1,
        'created_at': _now,
        'updated_at': _now,
      },
    ];
    for (final u in users) {
      await db.insert('users', u, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ── Patients ───────────────────────────────────────────────────────────────
  static Future<void> _insertPatients(Database db) async {
    for (final p in _patients) {
      await db.insert('patients', p,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> _insertAncVisits(Database db) async {
    for (final v in _ancVisits) {
      await db.insert('anc_visits', v,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> _insertDeliveries(Database db) async {
    for (final d in _deliveries) {
      await db.insert('delivery_records', d,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> _insertPostnatal(Database db) async {
    for (final p in _postnatal) {
      await db.insert('postnatal_records', p,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static Future<void> _insertFamilyPlanning(Database db) async {
    for (final f in _familyPlanning) {
      await db.insert('family_planning', f,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════════════════════════

  static final List<Map<String, dynamic>> _patients = [
    _p('p001','Apio Grace','1995-03-12','0772101001','Rubare Cell A','Rubare','Okello James','0772201001','2025-08-01','2026-05-08',2,1,'O+'),
    _p('p002','Nakato Fatuma','1998-07-22','0753102002','Rubare Cell B','Rubare','Ssenoga Ali','0753202002','2025-09-10','2026-06-17',1,0,'A+'),
    _p('p003','Akello Betty','1993-11-05','0782103003','Nyakabungo','Rubare','Mwesige Peter','0782203003','2025-07-15','2026-04-21',3,2,'B+'),
    _p('p004','Namukasa Rose','2000-01-30','0701104004','Rubare Cell C','Rubare','Ssemakula John','0701204004','2025-10-01','2026-07-08',1,0,'AB+'),
    _p('p005','Achola Stella','1997-05-18','0776105005','Kishanje','Rubare','Opio Charles','0776205005','2025-06-20','2026-03-27',2,1,'O-'),
    _p('p006','Nabukenya Diana','1999-09-09','0755106006','Rubare Cell A','Rubare','Mukasa David','0755206006','2025-11-05','2026-08-12',1,0,'A-'),
    _p('p007','Atim Prossy','1994-02-14','0783107007','Nyakabungo','Rubare','Otim Samuel','0783207007','2025-05-10','2026-02-14',4,3,'B-'),
    _p('p008','Nalwoga Susan','1996-08-27','0702108008','Rubare Cell B','Rubare','Nsubuga Robert','0702208008','2025-12-01','2026-09-07',2,1,'O+'),
    _p('p009','Aber Christine','2001-04-03','0777109009','Kishanje','Rubare','Ojok Martin','0777209009','2025-08-20','2026-05-27',1,0,'A+'),
    _p('p010','Namuganza Lydia','1992-12-19','0754110010','Rubare Cell C','Rubare','Kizito Fred','0754210010','2025-04-15','2026-01-19',5,4,'B+'),
    _p('p011','Akite Margret','1998-06-11','0784111011','Rubare Cell A','Rubare','Ayella Vincent','0784211011','2025-09-25','2026-07-01',2,1,'O+'),
    _p('p012','Nambooze Irene','1995-10-23','0703112012','Nyakabungo','Rubare','Ssali George','0703212012','2025-07-30','2026-05-05',3,2,'A+'),
    _p('p013','Adong Harriet','2000-03-07','0778113013','Rubare Cell B','Rubare','Okori Denis','0778213013','2025-11-12','2026-08-18',1,0,'B+'),
    _p('p014','Namatovu Agnes','1993-07-29','0752114014','Kishanje','Rubare','Muwanga Isaac','0752214014','2025-06-05','2026-03-12',4,3,'AB-'),
    _p('p015','Akello Joyce','1997-01-16','0785115015','Rubare Cell C','Rubare','Onen Patrick','0785215015','2025-10-18','2026-07-24',2,1,'O+'),
    _p('p016','Nalubega Fatuma','1999-05-04','0704116016','Rubare Cell A','Rubare','Ssentamu Henry','0704216016','2025-08-08','2026-05-15',1,0,'A+'),
    _p('p017','Auma Sarah','1994-09-21','0779117017','Nyakabungo','Rubare','Ogwang Thomas','0779217017','2025-05-22','2026-02-26',3,2,'B+'),
    _p('p018','Nassimbwa Joan','1996-02-08','0753118018','Rubare Cell B','Rubare','Kabuye Michael','0753218018','2025-12-15','2026-09-21',2,1,'O-'),
    _p('p019','Acen Doris','2001-06-25','0786119019','Kishanje','Rubare','Olweny Richard','0786219019','2025-09-02','2026-06-09',1,0,'A-'),
    _p('p020','Namukwaya Hellen','1992-10-12','0701120020','Rubare Cell C','Rubare','Ssekandi Joseph','0701220020','2025-04-28','2026-02-01',6,5,'B-'),
    _p('p021','Akello Martha','1997-04-19','0772121021','Rubare Cell A','Rubare','Okello Simon','0772221021','2025-10-05','2026-07-11',2,1,'O+'),
    _p('p022','Nakimuli Zainab','1999-08-31','0755122022','Nyakabungo','Rubare','Nkwanga Abdul','0755222022','2025-07-20','2026-04-26',1,0,'A+'),
    _p('p023','Adeke Florence','1995-12-07','0783123023','Rubare Cell B','Rubare','Omara Geoffrey','0783223023','2025-06-12','2026-03-19',3,2,'B+'),
    _p('p024','Nalugo Beatrice','1993-04-24','0702124024','Kishanje','Rubare','Mulindwa Steven','0702224024','2025-11-25','2026-09-01',4,3,'O+'),
    _p('p025','Aber Nancy','1998-08-11','0777125025','Rubare Cell C','Rubare','Ojok Andrew','0777225025','2025-08-14','2026-05-21',2,1,'A+'),
    _p('p026','Nalule Patience','2000-02-28','0754126026','Rubare Cell A','Rubare','Kato Emmanuel','0754226026','2025-09-18','2026-06-24',1,0,'B+'),
    _p('p027','Akello Sylvia','1994-06-15','0784127027','Nyakabungo','Rubare','Ayella Ronald','0784227027','2025-05-05','2026-02-09',5,4,'AB+'),
    _p('p028','Namusisi Rebecca','1996-10-02','0703128028','Rubare Cell B','Rubare','Ssali Paul','0703228028','2025-12-08','2026-09-14',2,1,'O+'),
    _p('p029','Adong Victoria','2001-02-19','0778129029','Kishanje','Rubare','Okori Francis','0778229029','2025-08-28','2026-06-04',1,0,'A-'),
    _p('p030','Nambooze Annet','1992-06-06','0752130030','Rubare Cell C','Rubare','Muwanga Rogers','0752230030','2025-04-10','2026-01-14',7,6,'B+'),
    _p('p031','Aciro Immaculate','1997-10-23','0785131031','Rubare Cell A','Rubare','Onen Richard','0785231031','2025-10-22','2026-07-28',2,1,'O+'),
    _p('p032','Namubiru Zamu','1999-03-10','0704132032','Nyakabungo','Rubare','Ssentamu Alex','0704232032','2025-07-08','2026-04-14',1,0,'A+'),
    _p('p033','Auma Lillian','1995-07-27','0779133033','Rubare Cell B','Rubare','Ogwang Nicholas','0779233033','2025-06-18','2026-03-25',3,2,'B-'),
    _p('p034','Nassozi Teddy','1993-11-13','0753134034','Kishanje','Rubare','Kabuye Lawrence','0753234034','2025-11-18','2026-08-24',4,3,'O-'),
    _p('p035','Acen Juliet','1998-03-01','0786135035','Rubare Cell C','Rubare','Olweny Kenneth','0786235035','2025-08-24','2026-05-31',2,1,'A+'),
    _p('p036','Nakyeyune Fiona','2000-07-18','0701136036','Rubare Cell A','Rubare','Ssekandi Dan','0701236036','2025-09-28','2026-07-04',1,0,'B+'),
    _p('p037','Akello Connie','1994-11-04','0772137037','Nyakabungo','Rubare','Okello Brian','0772237037','2025-05-15','2026-02-19',4,3,'O+'),
    _p('p038','Nalwanga Phiona','1996-03-21','0755138038','Rubare Cell B','Rubare','Nkwanga Hassan','0755238038','2025-12-22','2026-09-28',2,1,'A+'),
    _p('p039','Adeke Goretti','2001-09-07','0783139039','Kishanje','Rubare','Omara Geoffrey','0783239039','2025-08-10','2026-05-17',1,0,'B+'),
    _p('p040','Namutebi Harriet','1992-01-24','0702140040','Rubare Cell C','Rubare','Mulindwa Dan','0702240040','2025-03-25','2025-12-29',8,7,'AB+'),
    _p('p041','Aber Josephine','1997-05-11','0777141041','Rubare Cell A','Rubare','Ojok Samuel','0777241041','2025-10-10','2026-07-17',2,1,'O+'),
    _p('p042','Nalugembe Rahma','1999-09-28','0754142042','Nyakabungo','Rubare','Kato Rogers','0754242042','2025-07-24','2026-04-30',1,0,'A+'),
    _p('p043','Akello Jacinta','1995-01-14','0784143043','Rubare Cell B','Rubare','Ayella Mark','0784243043','2025-06-08','2026-03-15',3,2,'B+'),
    _p('p044','Namusoke Viola','1993-05-31','0703144044','Kishanje','Rubare','Ssali Timothy','0703244044','2025-11-28','2026-09-04',4,3,'O+'),
    _p('p045','Adong Winnie','1998-09-17','0778145045','Rubare Cell C','Rubare','Okori Moses','0778245045','2025-09-06','2026-06-13',2,1,'A-'),
    _p('p046','Namukasa Proscovia','2000-01-04','0752146046','Rubare Cell A','Rubare','Muwanga Denis','0752246046','2025-10-14','2026-07-20',1,0,'B-'),
    _p('p047','Apio Consolata','1994-05-21','0785147047','Nyakabungo','Rubare','Onen Godfrey','0785247047','2025-04-20','2026-01-24',5,4,'O+'),
    _p('p048','Nakamya Esther','1996-09-07','0704148048','Rubare Cell B','Rubare','Ssentamu Collins','0704248048','2025-12-28','2026-10-04',2,1,'A+'),
    _p('p049','Acen Gloria','2001-01-24','0779149049','Kishanje','Rubare','Ogwang Felix','0779249049','2025-08-18','2026-05-25',1,0,'B+'),
    _p('p050','Nabirye Lydia','1992-05-10','0753150050','Rubare Cell C','Rubare','Kabuye Godfrey','0753250050','2025-03-10','2025-12-14',9,8,'O+'),
    _p('p051','Akello Veronica','1997-09-27','0786151051','Rubare Cell A','Rubare','Olweny Moses','0786251051','2025-10-26','2026-08-01',2,1,'A+'),
    _p('p052','Nalubega Annet','1999-02-13','0701152052','Nyakabungo','Rubare','Ssekandi Fred','0701252052','2025-07-12','2026-04-18',1,0,'B+'),
    _p('p053','Auma Violet','1995-06-01','0772153053','Rubare Cell B','Rubare','Okello Oscar','0772253053','2025-06-26','2026-04-01',3,2,'O-'),
    _p('p054','Nassimbwa Ritah','1993-09-18','0755154054','Kishanje','Rubare','Nkwanga Yunus','0755254054','2025-12-05','2026-09-11',4,3,'A+'),
    _p('p055','Acen Brenda','1998-01-04','0783155055','Rubare Cell C','Rubare','Omara Herbert','0783255055','2025-09-12','2026-06-18',2,1,'B+'),
    _p('p056','Namutebi Sandra','2000-05-22','0702156056','Rubare Cell A','Rubare','Mulindwa Peter','0702256056','2025-10-30','2026-08-05',1,0,'O+'),
    _p('p057','Adong Josephine','1994-09-08','0777157057','Nyakabungo','Rubare','Ojok Lawrence','0777257057','2025-05-08','2026-02-12',5,4,'A-'),
    _p('p058','Nalwoga Annet','1996-01-25','0754158058','Rubare Cell B','Rubare','Kato Julius','0754258058','2025-01-05','2025-10-12',2,1,'B+'),
    _p('p059','Akello Penelope','2001-05-12','0784159059','Kishanje','Rubare','Ayella Simon','0784259059','2025-08-22','2026-05-29',1,0,'O+'),
    _p('p060','Namusisi Fatuma','1992-09-28','0703160060','Rubare Cell C','Rubare','Ssali Hamid','0703260060','2025-02-18','2025-11-24',8,7,'A+'),
    _p('p061','Aber Eunice','1997-01-14','0778161061','Rubare Cell A','Rubare','Okori Stephen','0778261061','2025-11-02','2026-08-08',2,1,'B+'),
    _p('p062','Nakimera Zamu','1999-05-02','0752162062','Nyakabungo','Rubare','Muwanga Nelson','0752262062','2025-07-16','2026-04-22',1,0,'O+'),
    _p('p063','Apio Harriet','1995-08-19','0785163063','Rubare Cell B','Rubare','Onen Collins','0785263063','2025-06-30','2026-04-05',3,2,'A+'),
    _p('p064','Nalule Doreen','1993-12-05','0704164064','Kishanje','Rubare','Ssentamu Richard','0704264064','2025-12-12','2026-09-18',4,3,'B-'),
    _p('p065','Acen Immaculate','1998-04-23','0779165065','Rubare Cell C','Rubare','Ogwang Timothy','0779265065','2025-09-16','2026-06-22',2,1,'O+'),
    _p('p066','Nakyeyune Phiona','2000-08-10','0753166066','Rubare Cell A','Rubare','Kabuye Andrew','0753266066','2025-10-04','2026-07-10',1,0,'A+'),
    _p('p067','Akello Olivia','1994-12-27','0786167067','Nyakabungo','Rubare','Olweny Bernard','0786267067','2025-04-14','2026-01-18',5,4,'B+'),
    _p('p068','Namubiru Goretti','1996-04-13','0701168068','Rubare Cell B','Rubare','Ssekandi Martin','0701268068','2025-01-18','2025-10-25',2,1,'O+'),
    _p('p069','Auma Connie','2001-08-01','0772169069','Kishanje','Rubare','Okello Phillip','0772269069','2025-08-26','2026-06-02',1,0,'A-'),
    _p('p070','Nassozi Immaculate','1992-12-17','0755170070','Rubare Cell C','Rubare','Nkwanga Ibrahim','0755270070','2025-02-02','2025-11-08',9,8,'B+'),
    _p('p071','Acen Penelope','1997-04-04','0783171071','Rubare Cell A','Rubare','Omara Charles','0783271071','2025-11-08','2026-08-14',2,1,'O+'),
    _p('p072','Nalugembe Violet','1999-07-22','0702172072','Nyakabungo','Rubare','Mulindwa Geoffrey','0702272072','2025-07-28','2026-05-03',1,0,'A+'),
    _p('p073','Adeke Sylvia','1995-11-08','0777173073','Rubare Cell B','Rubare','Ojok Bosco','0777273073','2025-06-14','2026-03-21',3,2,'B+'),
    _p('p074','Namutebi Fiona','1993-03-25','0754174074','Kishanje','Rubare','Kato Musa','0754274074','2025-12-18','2026-09-24',4,3,'O-'),
    _p('p075','Aber Consolata','1998-07-13','0784175075','Rubare Cell C','Rubare','Ayella Geoffrey','0784275075','2025-09-20','2026-06-26',2,1,'A+'),
    _p('p076','Nalwanga Jacqueline','2000-11-29','0703176076','Rubare Cell A','Rubare','Ssali Rashid','0703276076','2025-10-08','2026-07-14',1,0,'B+'),
    _p('p077','Akello Gertrude','1994-03-16','0778177077','Nyakabungo','Rubare','Okori Kizito','0778277077','2025-03-28','2025-01-01',5,4,'O+'),
    _p('p078','Namusoke Christine','1996-07-03','0752178078','Rubare Cell B','Rubare','Muwanga Bosco','0752278078','2025-01-22','2025-10-29',2,1,'A+'),
    _p('p079','Adong Constance','2001-10-20','0785179079','Kishanje','Rubare','Onen Isaac','0785279079','2025-08-30','2026-06-06',1,0,'B-'),
    _p('p080','Nakamya Proscovia','1992-02-05','0704180080','Rubare Cell C','Rubare','Ssentamu Godfrey','0704280080','2025-02-14','2025-11-20',8,7,'O+'),
    _p('p081','Aciro Sandra','1997-06-24','0779181081','Rubare Cell A','Rubare','Ogwang Kenneth','0779281081','2025-11-14','2026-08-20',2,1,'A+'),
    _p('p082','Nabirye Zamu','1999-10-11','0753182082','Nyakabungo','Rubare','Kabuye Phillip','0753282082','2025-07-02','2026-04-08',1,0,'B+'),
    _p('p083','Auma Winnie','1995-02-28','0786183083','Rubare Cell B','Rubare','Olweny Isaac','0786283083','2025-06-04','2026-03-11',3,2,'O+'),
    _p('p084','Nalubega Connie','1993-06-15','0701184084','Kishanje','Rubare','Ssekandi Phillip','0701284084','2025-12-24','2026-10-01',4,3,'A-'),
    _p('p085','Acen Winnie','1998-10-03','0772185085','Rubare Cell C','Rubare','Okello Herbert','0772285085','2025-09-24','2026-07-01',2,1,'B+'),
    _p('p086','Namuganza Phiona','2000-02-19','0755186086','Rubare Cell A','Rubare','Nkwanga Umar','0755286086','2025-10-18','2026-07-24',1,0,'O+'),
    _p('p087','Akello Patricia','1994-06-07','0783187087','Nyakabungo','Rubare','Omara Patrick','0783287087','2025-04-02','2026-01-06',6,5,'A+'),
    _p('p088','Namusisi Grace','1996-09-24','0702188088','Rubare Cell B','Rubare','Mulindwa Ronald','0702288088','2025-02-06','2025-11-12',2,1,'B+'),
    _p('p089','Adeke Rebecca','2001-01-11','0777189089','Kishanje','Rubare','Ojok Daniel','0777289089','2025-09-04','2026-06-11',1,0,'O-'),
    _p('p090','Nalugo Zamu','1992-05-28','0754190090','Rubare Cell C','Rubare','Kato Enock','0754290090','2025-01-28','2025-11-03',9,8,'A+'),
    _p('p091','Aber Daphine','1997-09-15','0784191091','Rubare Cell A','Rubare','Ayella Herbert','0784291091','2025-11-20','2026-08-26',2,1,'B+'),
    _p('p092','Nakamya Teddy','1999-01-02','0703192092','Nyakabungo','Rubare','Ssali Enock','0703292092','2025-08-06','2026-05-13',1,0,'O+'),
    _p('p093','Apio Daphine','1995-04-20','0778193093','Rubare Cell B','Rubare','Okori Bosco','0778293093','2025-07-04','2026-04-10',3,2,'A+'),
    _p('p094','Nalwoga Immaculate','1993-08-07','0752194094','Kishanje','Rubare','Muwanga Collins','0752294094','2025-12-30','2026-10-06',4,3,'B+'),
    _p('p095','Acen Annah','1998-12-25','0785195095','Rubare Cell C','Rubare','Onen Alex','0785295095','2025-09-08','2026-06-15',2,1,'O+'),
    _p('p096','Nakyeyune Winnie','2000-04-12','0704196096','Rubare Cell A','Rubare','Ssentamu Bosco','0704296096','2025-10-22','2026-07-28',1,0,'A+'),
    _p('p097','Akello Annah','1994-08-29','0779197097','Nyakabungo','Rubare','Ogwang Enock','0779297097','2025-04-08','2026-01-12',6,5,'B-'),
    _p('p098','Namubiru Lillian','1996-12-16','0753198098','Rubare Cell B','Rubare','Kabuye Daniel','0753298098','2025-02-20','2025-11-26',2,1,'O+'),
    _p('p099','Auma Daphine','2001-04-03','0786199099','Kishanje','Rubare','Olweny Alex','0786299099','2025-09-14','2026-06-21',1,0,'A-'),
    _p('p100','Nassimbwa Annah','1992-07-21','0701200100','Rubare Cell C','Rubare','Ssekandi Enock','0701300100','2025-01-12','2025-10-18',10,9,'B+'),
  ];

  static Map<String, dynamic> _p(
    String id, String name, String dob, String phone,
    String address, String village, String nok, String nokPhone,
    String lmp, String edd, int gravida, int parity, String bg,
  ) =>
      {
        'id': id,
        'full_name': name,
        'date_of_birth': dob,
        'phone': phone,
        'address': address,
        'village': village,
        'next_of_kin': nok,
        'nok_phone': nokPhone,
        'lmp': lmp,
        'edd': edd,
        'gravida': gravida,
        'parity': parity,
        'blood_group': bg,
        'registered_by': _recordedBy,
        'created_at': _now,
        'updated_at': _now,
      };

  // ── ANC Visits (2 per patient = 200 visits) ────────────────────────────────
  static final List<Map<String, dynamic>> _ancVisits = [
    for (int i = 1; i <= 100; i++) ...[
      _anc('a${i}v1', 'p${i.toString().padLeft(3,'0')}', 1,
          _offsetDate('2025-08-01', i * 2),      16, 58.0 + i * 0.1, 110 + i % 20, 70 + i % 10, 140 + i % 20, 18.0 + i * 0.1, 10.5 + i * 0.05, 'Normal', 0, 0, 0, 1, 1,
          _offsetDate('2025-08-01', i * 2 + 28), 'First visit, all normal.'),
      _anc('a${i}v2', 'p${i.toString().padLeft(3,'0')}', 2,
          _offsetDate('2025-08-01', i * 2 + 28), 20, 60.0 + i * 0.1, 112 + i % 18, 72 + i % 8,  142 + i % 18, 20.0 + i * 0.1, 11.0 + i * 0.04, 'Normal', 1, 0, 0, 2, 1,
          _offsetDate('2025-08-01', i * 2 + 56), 'Second visit, progressing well.'),
    ],
  ];

  static Map<String, dynamic> _anc(
    String id, String patientId, int visitNo, String visitDate,
    int gestWeeks, double weight, int bpS, int bpD, int fhr,
    double fh, double hb, String urine, int malaria, int hiv,
    int syphilis, int tetanus, int ironFolic, String nextDate, String notes,
  ) =>
      {
        'id': id,
        'patient_id': patientId,
        'visit_number': visitNo,
        'visit_date': visitDate,
        'gestation_weeks': gestWeeks,
        'weight_kg': weight,
        'bp_systolic': bpS,
        'bp_diastolic': bpD,
        'fetal_heartrate': fhr,
        'fundal_height': fh,
        'haemoglobin': hb,
        'urinalysis': urine,
        'malaria_test': malaria,
        'hiv_test': hiv,
        'syphilis_test': syphilis,
        'tetanus_dose': tetanus,
        'iron_folic_acid': ironFolic,
        'next_visit_date': nextDate,
        'notes': notes,
        'recorded_by': _recordedBy,
        'created_at': _now,
        'updated_at': _now,
      };

  // ── Deliveries (for first 60 patients) ────────────────────────────────────
  static final List<Map<String, dynamic>> _deliveries = [
    for (int i = 1; i <= 60; i++)
      _del(
        'del${i.toString().padLeft(3,'0')}',
        'p${i.toString().padLeft(3,'0')}',
        _offsetDate('2026-01-01', i),
        i % 5 == 0 ? 'caesarean' : 'vaginal',
        i % 15 == 0 ? 'stillbirth' : 'live_birth',
        2.8 + (i % 10) * 0.15,
        i % 2 == 0 ? 'Male' : 'Female',
        i % 15 == 0 ? 5 : (7 + i % 3),
        i % 10 == 0 ? 'PPH' : (i % 7 == 0 ? 'Prolonged labour' : 'None'),
        i % 5 == 0 ? 600.0 : 200.0 + i * 5,
        1,
        i % 10 == 0 ? 'Referred to hospital' : 'Uneventful delivery',
      ),
  ];

  static Map<String, dynamic> _del(
    String id, String patientId, String date, String type,
    String outcome, double birthWeight, String sex, int apgar,
    String complications, double bloodLoss, int placenta, String notes,
  ) =>
      {
        'id': id,
        'patient_id': patientId,
        'delivery_date': date,
        'delivery_type': type,
        'delivery_outcome': outcome,
        'birth_weight_kg': birthWeight,
        'baby_sex': sex,
        'apgar_score': apgar,
        'complications': complications,
        'blood_loss_ml': bloodLoss,
        'placenta_complete': placenta,
        'notes': notes,
        'recorded_by': _recordedBy,
        'created_at': _now,
      };

  // ── Postnatal (for first 50 patients) ─────────────────────────────────────
  static final List<Map<String, dynamic>> _postnatal = [
    for (int i = 1; i <= 50; i++)
      _pnc(
        'pnc${i.toString().padLeft(3,'0')}',
        'p${i.toString().padLeft(3,'0')}',
        _offsetDate('2026-01-15', i),
        1,
        110 + i % 20, 70 + i % 10,
        36.5 + (i % 5) * 0.1,
        i % 3 == 0 ? 'Heavy' : 'Normal',
        1,
        3.0 + (i % 10) * 0.1,
        36.6 + (i % 4) * 0.1,
        i % 8 == 0 ? 'Mother reported fever — referred' : 'Both mother and baby doing well.',
      ),
  ];

  static Map<String, dynamic> _pnc(
    String id, String patientId, String date, int visitNo,
    int bpS, int bpD, double temp, String lochia, int bf,
    double babyWeight, double babyTemp, String notes,
  ) =>
      {
        'id': id,
        'patient_id': patientId,
        'visit_date': date,
        'visit_number': visitNo,
        'mother_bp_s': bpS,
        'mother_bp_d': bpD,
        'mother_temp': temp,
        'lochia': lochia,
        'breastfeeding': bf,
        'baby_weight': babyWeight,
        'baby_temp': babyTemp,
        'notes': notes,
        'recorded_by': _recordedBy,
        'created_at': _now,
      };

  // ── Family Planning (for first 40 patients) ────────────────────────────────
  static const _fpMethods = [
    'Injectable (Depo-Provera)',
    'Implant (Jadelle)',
    'IUCD',
    'Oral Contraceptive Pills',
    'Condoms',
    'Natural Family Planning',
  ];

  static final List<Map<String, dynamic>> _familyPlanning = [
    for (int i = 1; i <= 40; i++)
      _fp(
        'fp${i.toString().padLeft(3,'0')}',
        'p${i.toString().padLeft(3,'0')}',
        _offsetDate('2026-02-01', i),
        _fpMethods[i % _fpMethods.length],
        i % 4 == 0 ? 0 : 1,
        _offsetDate('2026-02-01', i + 90),
        i % 5 == 0 ? 'Client counselled on side effects' : 'No concerns raised',
      ),
  ];

  static Map<String, dynamic> _fp(
    String id, String patientId, String date, String method,
    int isNew, String followUp, String notes,
  ) =>
      {
        'id': id,
        'patient_id': patientId,
        'service_date': date,
        'method': method,
        'is_new_client': isNew,
        'follow_up': followUp,
        'notes': notes,
        'recorded_by': _recordedBy,
        'created_at': _now,
      };

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String _offsetDate(String base, int daysOffset) {
    final d = DateTime.parse(base).add(Duration(days: daysOffset));
    return d.toIso8601String().substring(0, 10);
  }
}