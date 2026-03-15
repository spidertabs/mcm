// lib/presentation/reports/reports_screen.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/storage/database_helper.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _from = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _to = DateTime.now();
  bool _isGenerating = false;
  String? _generatingName;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _safe(String? s) {
    if (s == null || s.isEmpty) return 'N/A';
    return s.replaceAll(RegExp(r'[^\x00-\x7F]'), '?')
        .replaceAll('\u2013', '-').replaceAll('\u2014', '-');
  }

  String _fmtIso(String? iso) {
    if (iso == null) return 'N/A';
    try { return _fmt(DateTime.parse(iso)); } catch (_) { return _safe(iso); }
  }

  String _bp(dynamic sys, dynamic dia) =>
      (sys == null || dia == null) ? 'N/A' : '$sys/$dia';

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => isFrom ? _from = d : _to = d);
  }

  Future<void> _generate(String reportName) async {
    setState(() { _isGenerating = true; _generatingName = reportName; });
    try {
      final bytes = await _buildPdfBytes(reportName);
      final safeName = reportName.replaceAll(' ', '_');
      final filename = '${safeName}_${_fmt(_from)}_to_${_fmt(_to)}.pdf'
          .replaceAll('/', '-');

      if (kIsWeb) {
        // Web — share directly
        await Printing.sharePdf(bytes: bytes, filename: filename);
      } else {
        // Mobile & Desktop — save to temp file then share/print
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);

        await Printing.sharePdf(
          bytes: bytes,
          filename: filename,
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: const Color(0xFFEF4444)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<Uint8List> _buildPdfBytes(String reportName) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final range = '${_fmt(_from)} to ${_fmt(_to)}';
    final pdf = pw.Document();

    if (reportName == 'Comprehensive Monthly Report') {
      final results = await Future.wait([
        db.rawQuery('SELECT COUNT(*) as c FROM patients'),
        db.rawQuery('SELECT COUNT(*) as c FROM anc_visits WHERE visit_date BETWEEN ? AND ?', [_from.toIso8601String(), _to.toIso8601String()]),
        db.rawQuery('SELECT COUNT(*) as c FROM delivery_records WHERE delivery_date BETWEEN ? AND ?', [_from.toIso8601String(), _to.toIso8601String()]),
        db.rawQuery('SELECT COUNT(*) as c FROM postnatal_records WHERE visit_date BETWEEN ? AND ?', [_from.toIso8601String(), _to.toIso8601String()]),
        db.rawQuery('SELECT COUNT(*) as c FROM family_planning WHERE service_date BETWEEN ? AND ?', [_from.toIso8601String(), _to.toIso8601String()]),
        db.rawQuery("SELECT COUNT(*) as c FROM patients WHERE risk_level='high' OR gravida>=4"),
        db.rawQuery("SELECT COUNT(*) as c FROM delivery_records WHERE delivery_outcome='live_birth' AND delivery_date BETWEEN ? AND ?", [_from.toIso8601String(), _to.toIso8601String()]),
      ]);
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfHeader(reportName, range, _fmt(now)),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['Metric', 'Count'],
              data: [
                ['Total Registered Patients', '${results[0].first['c']}'],
                ['ANC Visits (period)', '${results[1].first['c']}'],
                ['Deliveries (period)', '${results[2].first['c']}'],
                ['Live Births (period)', '${results[6].first['c']}'],
                ['Postnatal Visits (period)', '${results[3].first['c']}'],
                ['Family Planning Services (period)', '${results[4].first['c']}'],
                ['High Risk Patients (total)', '${results[5].first['c']}'],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
              cellStyle: const pw.TextStyle(fontSize: 11),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.purple50),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            ),
          ],
        ),
      ));
    } else {
      List<Map<String, dynamic>> rows;
      List<String> headers;
      List<List<String>> data;
      String summary;

      switch (reportName) {
        case 'ANC Monthly Summary':
          rows = await db.rawQuery('''SELECT av.*, p.full_name FROM anc_visits av LEFT JOIN patients p ON av.patient_id = p.id WHERE av.visit_date BETWEEN ? AND ? ORDER BY av.visit_date DESC''', [_from.toIso8601String(), _to.toIso8601String()]);
          headers = ['Patient', 'Visit', 'Date', 'GA wks', 'BP', 'Wt kg', 'Hb'];
          data = rows.map((r) => [_safe(r['full_name']?.toString() ?? r['patient_id']?.toString()), _safe(r['visit_number']?.toString()), _fmtIso(r['visit_date']?.toString()), _safe(r['gestation_weeks']?.toString()), _bp(r['bp_systolic'], r['bp_diastolic']), _safe(r['weight_kg']?.toString()), _safe(r['haemoglobin']?.toString())]).toList();
          summary = 'Total ANC visits: ${rows.length}';
          break;
        case 'Delivery Summary':
          rows = await db.rawQuery('''SELECT dr.*, p.full_name FROM delivery_records dr LEFT JOIN patients p ON dr.patient_id = p.id WHERE dr.delivery_date BETWEEN ? AND ? ORDER BY dr.delivery_date DESC''', [_from.toIso8601String(), _to.toIso8601String()]);
          headers = ['Patient', 'Date', 'Mode', 'Outcome', 'Wt kg', 'Sex', 'APGAR'];
          final live = rows.where((r) => r['delivery_outcome'] == 'live_birth').length;
          final cs = rows.where((r) => r['delivery_type'] == 'cs').length;
          data = rows.map((r) => [_safe(r['full_name']?.toString() ?? r['patient_id']?.toString()), _fmtIso(r['delivery_date']?.toString()), _safe(r['delivery_type']?.toString()?.toUpperCase()), _safe(r['delivery_outcome']?.toString()?.replaceAll('_', ' ')), _safe(r['birth_weight_kg']?.toString()), _safe(r['baby_sex']?.toString()), _safe(r['apgar_score']?.toString())]).toList();
          summary = 'Total: ${rows.length} | Live births: $live | C/S: $cs';
          break;
        case 'Postnatal Follow-up Report':
          rows = await db.rawQuery('''SELECT pr.*, p.full_name FROM postnatal_records pr LEFT JOIN patients p ON pr.patient_id = p.id WHERE pr.visit_date BETWEEN ? AND ? ORDER BY pr.visit_date DESC''', [_from.toIso8601String(), _to.toIso8601String()]);
          headers = ['Patient', 'Visit', 'Date', 'BP', 'Temp C', 'Baby Wt', 'BF'];
          data = rows.map((r) => [_safe(r['full_name']?.toString() ?? r['patient_id']?.toString()), 'Visit ${r['visit_number']}', _fmtIso(r['visit_date']?.toString()), _bp(r['mother_bp_s'], r['mother_bp_d']), _safe(r['mother_temp']?.toString()), _safe(r['baby_weight']?.toString()), (r['breastfeeding'] as int?) == 1 ? 'Yes' : 'No']).toList();
          summary = 'Total postnatal visits: ${rows.length}';
          break;
        case 'Family Planning Report':
          rows = await db.rawQuery('''SELECT fp.*, p.full_name FROM family_planning fp LEFT JOIN patients p ON fp.patient_id = p.id WHERE fp.service_date BETWEEN ? AND ? ORDER BY fp.service_date DESC''', [_from.toIso8601String(), _to.toIso8601String()]);
          headers = ['Patient', 'Method', 'Date', 'New', 'Follow-up'];
          final newC = rows.where((r) => (r['is_new_client'] as int?) == 1).length;
          data = rows.map((r) => [_safe(r['full_name']?.toString() ?? r['patient_id']?.toString()), _safe(r['method']?.toString()), _fmtIso(r['service_date']?.toString()), (r['is_new_client'] as int?) == 1 ? 'Yes' : 'No', _fmtIso(r['follow_up']?.toString())]).toList();
          summary = 'Total: ${rows.length} | New acceptors: $newC';
          break;
        default:
          rows = await db.rawQuery("SELECT * FROM patients WHERE risk_level='high' OR gravida>=4 ORDER BY full_name ASC");
          headers = ['Name', 'DOB', 'Phone', 'Gravida', 'Parity', 'Blood Grp', 'Risk'];
          data = rows.map((r) => [_safe(r['full_name']?.toString()), _fmtIso(r['date_of_birth']?.toString()), _safe(r['phone']?.toString()), _safe(r['gravida']?.toString()), _safe(r['parity']?.toString()), _safe(r['blood_group']?.toString()), _safe(r['risk_level']?.toString()?.toUpperCase())]).toList();
          summary = 'Total high-risk patients: ${rows.length}';
      }

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _pdfHeader(reportName, range, _fmt(now)),
            pw.SizedBox(height: 10),
            pw.Expanded(child: pw.TableHelper.fromTextArray(
              headers: headers, data: data,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.purple700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              rowDecoration: const pw.BoxDecoration(color: PdfColors.purple50),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              cellAlignments: {for (int i = 0; i < headers.length; i++) i: pw.Alignment.centerLeft},
            )),
            pw.SizedBox(height: 6),
            pw.Text(_safe(summary), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.purple900)),
          ],
        ),
      ));
    }
    return pdf.save();
  }

  pw.Widget _pdfHeader(String title, String range, String generated) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text('MaternalCare Monitor - Rubare Town Council',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700)),
        pw.Text('Generated: $generated',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ]),
      pw.SizedBox(height: 6),
      pw.Text(_safe(title), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.purple900)),
      pw.Text('Period: $range', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
      pw.Divider(color: PdfColors.purple200),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final reports = [
      ('ANC Monthly Summary', 'ANC visits, gestational ages, BP and Hb', Icons.pregnant_woman_outlined, const Color(0xFF0EA5E9)),
      ('Delivery Summary', 'Delivery outcomes, modes, birth weights', Icons.local_hospital_outlined, const Color(0xFF10B981)),
      ('Postnatal Follow-up Report', 'Postnatal visits, breastfeeding, baby weight', Icons.child_care_outlined, const Color(0xFF6366F1)),
      ('Family Planning Report', 'Contraceptive methods, new vs continuing', Icons.health_and_safety_outlined, const Color(0xFFF59E0B)),
      ('High Risk Patients', 'Patients flagged as high risk', Icons.warning_amber_outlined, const Color(0xFFEF4444)),
      ('Comprehensive Monthly Report', 'Full summary — suitable for HMIS submission', Icons.summarize_outlined, const Color(0xFF8B5CF6)),
    ];

    return AppScaffold(
      title: AppStrings.reports,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range picker
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.date_range_outlined, size: 15, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 6),
                        Text(AppStrings.selectDateRange,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _DateButton(label: 'From', date: _from, fmt: _fmt, onTap: () => _pickDate(true))),
                        const SizedBox(width: 10),
                        Expanded(child: _DateButton(label: 'To', date: _to, fmt: _fmt, onTap: () => _pickDate(false))),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Available Reports',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const SizedBox(height: 10),
                ...reports.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ReportCard(
                    title: r.$1,
                    description: r.$2,
                    icon: r.$3,
                    color: r.$4,
                    isGenerating: _isGenerating && _generatingName == r.$1,
                    onGenerate: () => _generate(r.$1),
                  ),
                )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final String Function(DateTime) fmt;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.date, required this.fmt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Text('$label: ${fmt(date)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isGenerating;
  final VoidCallback onGenerate;
  const _ReportCard({required this.title, required this.description, required this.icon, required this.color, required this.isGenerating, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 12),
        SizedBox(
          height: 32,
          child: FilledButton(
            onPressed: isGenerating ? null : onGenerate,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: Size.zero,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            child: isGenerating
                ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withValues(alpha: 0.8)))
                : const Text('Generate'),
          ),
        ),
      ]),
    );
  }
}