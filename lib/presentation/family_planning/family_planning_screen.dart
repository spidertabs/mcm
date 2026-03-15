// lib/presentation/family_planning/family_planning_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/family_planning_provider.dart';
import '../../data/models/family_planning_model.dart';
import '../../domain/entities/family_planning_entity.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class FamilyPlanningScreen extends ConsumerWidget {
  const FamilyPlanningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyPlanningListProvider);

    return AppScaffold(
      title: AppStrings.familyPlanning,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Service'),
        backgroundColor: const Color(0xFFF59E0B),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(familyPlanningListProvider.notifier).load(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? ErrorState(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(familyPlanningListProvider.notifier).load(),
                  )
                : CustomScrollView(
                    slivers: [
                      // Method summary chips
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 960),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 0),
                              child: _MethodSummary(
                                  counts: state.methodCounts),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 960),
                            child: const Padding(
                              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                              child: Text(
                                'Recent Services',
                                style: TextStyle(
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
                            icon: Icons.health_and_safety_outlined,
                            title: 'No family planning records yet',
                            subtitle: 'Tap + to record a service',
                            color: Color(0xFFF59E0B),
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
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 0, 20, 0),
                                  child: _FpTile(
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

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FpFormSheet(
        onSaved: () =>
            ref.read(familyPlanningListProvider.notifier).load(),
      ),
    );
  }
}

// ── Method summary ────────────────────────────────────────────────────────────
class _MethodSummary extends StatelessWidget {
  final Map<String, int> counts;
  const _MethodSummary({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 15, color: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              Text(
                'Contraceptive Methods — This Month',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          counts.isEmpty
              ? const Text(
                  'No services recorded this month',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8)),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: counts.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${e.key}: ${e.value}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

// ── FP tile ───────────────────────────────────────────────────────────────────
class _FpTile extends StatelessWidget {
  final FamilyPlanningEntity record;
  const _FpTile({required this.record});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _name =>
      record is FamilyPlanningModel
          ? (record as FamilyPlanningModel).patientName ??
              'Patient ${record.patientId}'
          : 'Patient ${record.patientId}';

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return RecordCard(
      leading: RecordAvatar(
        initials: _initials,
        color: const Color(0xFFF59E0B),
        bg: const Color(0xFFFEF3C7),
      ),
      title: Text(
        _name,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        '${record.method}  ·  ${_fmt(record.serviceDate)}'
        '${record.isNewClient ? '  ·  New acceptor' : ''}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),
      trailing: record.followUp != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Next visit',
                    style: TextStyle(
                        fontSize: 9, color: Color(0xFFCBD5E1))),
                Text(
                  _fmt(record.followUp!),
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600),
                ),
              ],
            )
          : null,
    );
  }
}

// ── Add service bottom sheet ──────────────────────────────────────────────────
class _FpFormSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _FpFormSheet({required this.onSaved});

  @override
  ConsumerState<_FpFormSheet> createState() => _FpFormSheetState();
}

class _FpFormSheetState extends ConsumerState<_FpFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _serviceDateController = TextEditingController();
  final _notesController = TextEditingController();
  String _method = 'implant';
  bool _isNewAcceptor = true;
  bool _isLoading = false;

  static const _methods = {
    'implant': 'Implant',
    'iud': 'IUD (IUCD)',
    'pills': 'Combined Oral Contraceptive Pills',
    'pop': 'Progestogen-Only Pills (POP)',
    'injection': 'Injectable (Depo-Provera)',
    'condoms': 'Condoms',
    'sterilization_f': 'Female Sterilization',
    'sterilization_m': 'Male Sterilization',
    'nfp': 'Natural Family Planning',
    'other': 'Other',
  };

  @override
  void dispose() {
    _patientController.dispose();
    _serviceDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.recordSaved)));
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text('New Family Planning Service',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientController,
                decoration: const InputDecoration(
                    labelText: 'Patient *',
                    prefixIcon: Icon(Icons.person_search)),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Required'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _method,
                decoration: const InputDecoration(
                    labelText: AppStrings.contraceptiveMethod,
                    prefixIcon: Icon(Icons.health_and_safety_outlined)),
                items: _methods.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _method = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serviceDateController,
                readOnly: true,
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    _serviceDateController.text =
                        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                  }
                },
                decoration: const InputDecoration(
                    labelText: '${AppStrings.serviceDate} *',
                    prefixIcon: Icon(Icons.calendar_today)),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                title: const Text('New Acceptor',
                    style: TextStyle(fontSize: 13)),
                subtitle: const Text(
                    'First time using this method',
                    style: TextStyle(fontSize: 11)),
                value: _isNewAcceptor,
                onChanged: (v) => setState(() => _isNewAcceptor = v),
                activeColor: const Color(0xFFF59E0B),
                contentPadding: EdgeInsets.zero,
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note_outlined)),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _isLoading
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Service Record',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}