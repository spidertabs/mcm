// lib/presentation/anc/anc_screen.dart
// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/anc_provider.dart';
import '../../domain/entities/anc_visit_entity.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class AncScreen extends ConsumerWidget {
  const AncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ancListProvider);
    final notifier = ref.read(ancListProvider.notifier);

    return AppScaffold(
      title: AppStrings.anc,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.ancNew),
        icon: const Icon(Icons.add),
        label: const Text('New ANC Visit'),
        backgroundColor: const Color(0xFF8B5CF6),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ancListProvider.notifier).load(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? ErrorState(
                    message: state.error!,
                    onRetry: () => ref.read(ancListProvider.notifier).load(),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 960),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 20, 20, 0),
                              child: SummaryBar(items: [
                                (
                                  label: 'This Month',
                                  value:
                                      '${notifier.thisMonthCount}',
                                  color: const Color(0xFF8B5CF6),
                                ),
                                (
                                  label: 'ANC 1st Visit',
                                  value:
                                      '${notifier.firstVisitCount}',
                                  color: const Color(0xFF0EA5E9),
                                ),
                                (
                                  label: 'ANC 4+ Visits',
                                  value:
                                      '${notifier.fourPlusVisitPatients}',
                                  color: const Color(0xFF10B981),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                      if (state.visits.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.pregnant_woman_outlined,
                            title: 'No ANC visits recorded',
                            subtitle: 'Tap + to record the first visit',
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 960),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      20,
                                      i == 0 ? 12 : 0,
                                      20,
                                      0),
                                  child: _AncTile(
                                      visit: state.visits[i]),
                                ),
                              ),
                            ),
                            childCount: state.visits.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                          child: SizedBox(height: 80)),
                    ],
                  ),
      ),
    );
  }
}

// ── ANC tile ──────────────────────────────────────────────────────────────────
class _AncTile extends StatelessWidget {
  final AncVisitEntity visit;
  const _AncTile({required this.visit});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _patientName =>
      visit.patientName ?? 'Patient ${visit.patientId}';

  String get _initials {
    final parts = _patientName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _patientName.substring(0, 2).toUpperCase();
  }

  bool get _isHighBP {
    final sys = visit.bpSystolic;
    final dia = visit.bpDiastolic;
    if (sys == null || dia == null) return false;
    return sys >= 140 || dia >= 90;
  }

  @override
  Widget build(BuildContext context) {
    return RecordCard(
      leading: RecordAvatar(
        initials: '${visit.visitNumber}',
        color: const Color(0xFF8B5CF6),
        bg: const Color(0xFFEDE9FE),
        size: 40,
      ),
      title: Text(
        _patientName,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        'Visit ${visit.visitNumber}  ·  ${_fmt(visit.visitDate)}'
        '${visit.gestationalAge != null ? '  ·  ${visit.gestationalAge} wks' : ''}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (visit.bloodPressure != null)
            StatusChip(
              label: visit.bloodPressure!,
              color: _isHighBP
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
              bg: _isHighBP
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFD1FAE5),
            ),
        ],
      ),
    );
  }
}

// ── ANC Form Screen ───────────────────────────────────────────────────────────
class AncFormScreen extends ConsumerStatefulWidget {
  const AncFormScreen({super.key});

  @override
  ConsumerState<AncFormScreen> createState() => _AncFormScreenState();
}

class _AncFormScreenState extends ConsumerState<AncFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _visitDateController = TextEditingController();
  final _bpController = TextEditingController();
  final _weightController = TextEditingController();
  final _fhrController = TextEditingController();
  final _fundalController = TextEditingController();
  final _hbController = TextEditingController();
  final _notesController = TextEditingController();
  final _nextVisitController = TextEditingController();
  bool _isLoading = false;
  bool _ironFolicAcid = false;

  @override
  void dispose() {
    _patientController.dispose();
    _visitDateController.dispose();
    _bpController.dispose();
    _weightController.dispose();
    _fhrController.dispose();
    _fundalController.dispose();
    _hbController.dispose();
    _notesController.dispose();
    _nextVisitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoading = false);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ANC visit recorded')));
      ref.read(ancListProvider.notifier).load();
    }
  }

  Widget _card(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B5CF6),
                    fontSize: 13)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool required = false,
      bool isDate = false,
      TextInputType? keyboardType,
      int maxLines = 1,
      Function(DateTime)? onDatePicked}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) {
                  c.text =
                      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                  onDatePicked?.call(d);
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon),
        ),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? '$label is required' : null
            : null,
        enabled: !_isLoading,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New ANC Visit')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _card('Patient & Visit', [
                  _field(_patientController, 'Patient', Icons.person_search,
                      required: true),
                  _field(_visitDateController, 'Visit Date',
                      Icons.calendar_today,
                      required: true, isDate: true),
                ]),
                _card('Measurements', [
                  _field(_bpController, 'Blood Pressure',
                      Icons.monitor_heart_outlined),
                  _field(_weightController, 'Weight (kg)',
                      Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number),
                  _field(_fhrController, 'Fetal Heart Rate (bpm)',
                      Icons.favorite_outline,
                      keyboardType: TextInputType.number),
                  _field(_fundalController, 'Fundal Height (cm)',
                      Icons.straighten,
                      keyboardType: TextInputType.number),
                  _field(_hbController, 'Haemoglobin (g/dL)',
                      Icons.water_drop_outlined,
                      keyboardType: TextInputType.number),
                ]),
                _card('Treatment', [
                  SwitchListTile(
                    title: const Text('Iron/Folic Acid Given'),
                    value: _ironFolicAcid,
                    onChanged: (v) => setState(() => _ironFolicAcid = v),
                    activeColor: const Color(0xFF8B5CF6),
                    contentPadding: EdgeInsets.zero,
                  ),
                  _field(_nextVisitController, 'Next Visit Date',
                      Icons.calendar_month,
                      isDate: true),
                  _field(_notesController, 'Notes', Icons.note_outlined,
                      maxLines: 3),
                ]),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Record ANC Visit',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}