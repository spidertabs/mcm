// lib/presentation/postnatal/postnatal_screen.dart
// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/postnatal_provider.dart';
import '../../data/models/postnatal_model.dart';
import '../../domain/entities/postnatal_entity.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class PostnatalScreen extends ConsumerWidget {
  const PostnatalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postnatalListProvider);

    return AppScaffold(
      title: AppStrings.postnatal,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.postnatalNew),
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(postnatalListProvider.notifier).load(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? ErrorState(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(postnatalListProvider.notifier).load(),
                  )
                : CustomScrollView(
                    slivers: [
                      // Due today banner
                      if (state.dueToday.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 960),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 16, 20, 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFF59E0B)
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.notifications_active,
                                          color: Color(0xFFF59E0B),
                                          size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${state.dueToday.length} patient${state.dueToday.length == 1 ? '' : 's'} due for postnatal visit today',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF92400E),
                                              fontWeight:
                                                  FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 960),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20, 16, 20, 4),
                              child: Text(
                                'Recent Postnatal Visits',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (state.records.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.child_care_outlined,
                            title: 'No postnatal visits recorded',
                            subtitle: 'Tap + to record a visit',
                            color: Color(0xFF6366F1),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: _PostnatalTile(
                                      record: state.records[i]),
                                ),
                              ),
                            ),
                            childCount: state.records.length,
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

class _PostnatalTile extends StatelessWidget {
  final PostnatalEntity record;
  const _PostnatalTile({required this.record});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _name =>
      record is PostnatalModel
          ? (record as PostnatalModel).patientName ??
              'Patient ${record.patientId}'
          : 'Patient ${record.patientId}';

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _name.substring(0, 2).toUpperCase();
  }

  String get _visitLabel {
    switch (record.visitNumber) {
      case 1: return 'Day 1';
      case 2: return 'Day 3';
      case 3: return 'Week 1';
      case 4: return 'Week 6';
      default: return 'Visit ${record.visitNumber}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RecordCard(
      leading: RecordAvatar(
        initials: _initials,
        color: const Color(0xFF6366F1),
        bg: const Color(0xFFEEF2FF),
      ),
      title: Text(
        _name,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        '$_visitLabel  ·  ${_fmt(record.visitDate)}'
        '${record.babyWeight != null ? '  ·  Baby: ${record.babyWeight!.toStringAsFixed(1)} kg' : ''}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (record.breastfeeding == true)
            const StatusChip(
              label: 'Breastfeeding',
              color: Color(0xFF10B981),
              bg: Color(0xFFD1FAE5),
            ),
        ],
      ),
    );
  }
}

// ── Postnatal Form Screen ─────────────────────────────────────────────────────
class PostnatalFormScreen extends ConsumerStatefulWidget {
  const PostnatalFormScreen({super.key});

  @override
  ConsumerState<PostnatalFormScreen> createState() =>
      _PostnatalFormScreenState();
}

class _PostnatalFormScreenState extends ConsumerState<PostnatalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _visitDateController = TextEditingController();
  final _motherBpController = TextEditingController();
  final _motherTempController = TextEditingController();
  final _babyWeightController = TextEditingController();
  final _notesController = TextEditingController();
  bool _breastfeeding = true;
  bool _fpCounselled = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _patientController.dispose();
    _visitDateController.dispose();
    _motherBpController.dispose();
    _motherTempController.dispose();
    _babyWeightController.dispose();
    _notesController.dispose();
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
          const SnackBar(content: Text('Postnatal visit recorded')));
      ref.read(postnatalListProvider.notifier).load();
    }
  }

  Widget _card(String title, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                      fontSize: 13)),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool required = false,
      bool isDate = false,
      TextInputType? keyboardType,
      int maxLines = 1}) {
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
      appBar: AppBar(title: const Text('New Postnatal Visit')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _card('Visit Details', [
                  _field(_patientController, 'Patient', Icons.person_search,
                      required: true),
                  _field(_visitDateController, 'Visit Date',
                      Icons.calendar_today,
                      required: true, isDate: true),
                ]),
                _card("Mother's Assessment", [
                  _field(_motherBpController, 'Blood Pressure',
                      Icons.monitor_heart_outlined),
                  _field(_motherTempController, 'Temperature (C)',
                      Icons.thermostat,
                      keyboardType: TextInputType.number),
                  SwitchListTile(
                    title: const Text('Breastfeeding'),
                    value: _breastfeeding,
                    onChanged: (v) => setState(() => _breastfeeding = v),
                    activeColor: const Color(0xFF6366F1),
                    contentPadding: EdgeInsets.zero,
                  ),
                ]),
                _card("Baby's Assessment", [
                  _field(_babyWeightController, 'Baby Weight (kg)',
                      Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number),
                ]),
                _card('Other', [
                  SwitchListTile(
                    title: const Text('Family Planning Counselled'),
                    value: _fpCounselled,
                    onChanged: (v) => setState(() => _fpCounselled = v),
                    activeColor: const Color(0xFF6366F1),
                    contentPadding: EdgeInsets.zero,
                  ),
                  _field(_notesController, 'Notes', Icons.note_outlined,
                      maxLines: 3),
                ]),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Record Postnatal Visit',
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