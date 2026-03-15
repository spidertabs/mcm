// lib/presentation/delivery/delivery_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/delivery_provider.dart';
import '../../data/models/delivery_model.dart';
import '../../domain/entities/delivery_entity.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class DeliveryScreen extends ConsumerWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveryListProvider);

    return AppScaffold(
      title: AppStrings.delivery,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.deliveryNew),
        icon: const Icon(Icons.add),
        label: const Text('New Delivery'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(deliveryListProvider.notifier).load(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? ErrorState(
                    message: state.error!,
                    onRetry: () =>
                        ref.read(deliveryListProvider.notifier).load(),
                  )
                : state.deliveries.isEmpty
                    ? const EmptyState(
                        icon: Icons.local_hospital_outlined,
                        title: 'No deliveries recorded',
                        subtitle: 'Tap + to log the first delivery',
                        color: Color(0xFF10B981),
                      )
                    : _DeliveryList(deliveries: state.deliveries),
      ),
    );
  }
}

class _DeliveryList extends StatelessWidget {
  final List<DeliveryEntity> deliveries;
  const _DeliveryList({required this.deliveries});

  // Compute summary counts
  int get _liveBirths =>
      deliveries.where((d) => d.birthOutcome == BirthOutcome.liveBirth).length;
  int get _stillbirths =>
      deliveries.where((d) => d.birthOutcome == BirthOutcome.stillbirth).length;
  int get _csCount =>
      deliveries.where((d) => d.deliveryMode == DeliveryMode.cs).length;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SummaryBar(items: [
                  (
                    label: 'Total',
                    value: '${deliveries.length}',
                    color: const Color(0xFF10B981),
                  ),
                  (
                    label: 'Live Births',
                    value: '$_liveBirths',
                    color: const Color(0xFF0EA5E9),
                  ),
                  (
                    label: 'Stillbirths',
                    value: '$_stillbirths',
                    color: const Color(0xFFEF4444),
                  ),
                  (
                    label: 'C/S',
                    value: '$_csCount',
                    color: const Color(0xFFF59E0B),
                  ),
                ]),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, i == 0 ? 12 : 0, 20, 0),
                  child: _DeliveryTile(delivery: deliveries[i]),
                ),
              ),
            ),
            childCount: deliveries.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final DeliveryEntity delivery;
  const _DeliveryTile({required this.delivery});

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _name =>
      delivery is DeliveryModel
          ? (delivery as DeliveryModel).patientName ??
              'Patient ${delivery.patientId}'
          : 'Patient ${delivery.patientId}';

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _name.substring(0, 2).toUpperCase();
  }

  bool get _isLiveBirth => delivery.birthOutcome == BirthOutcome.liveBirth;
  bool get _isCs => delivery.deliveryMode == DeliveryMode.cs;
  bool get _isLbw =>
      delivery.birthWeightKg != null && delivery.birthWeightKg! < 2.5;

  @override
  Widget build(BuildContext context) {
    return RecordCard(
      leading: RecordAvatar(
        initials: _initials,
        color: const Color(0xFF10B981),
        bg: const Color(0xFFD1FAE5),
      ),
      title: Text(
        _name,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        '${_fmt(delivery.deliveryDate)}'
        '  ·  ${delivery.deliveryMode.label}'
        '${delivery.birthWeightKg != null ? '  ·  ${delivery.birthWeightKg!.toStringAsFixed(2)} kg' : ''}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLbw)
            const StatusChip(
              label: 'Low BW',
              color: Color(0xFFEF4444),
              bg: Color(0xFFFEF2F2),
            ),
          if (_isLbw) const SizedBox(width: 4),
          if (_isCs)
            const StatusChip(
              label: 'C/S',
              color: Color(0xFFF59E0B),
              bg: Color(0xFFFEF3C7),
            ),
          if (_isCs) const SizedBox(width: 4),
          StatusChip(
            label: _isLiveBirth ? 'Live Birth' : 'Stillbirth',
            color: _isLiveBirth
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            bg: _isLiveBirth
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }
}

// ── Delivery Form Screen ──────────────────────────────────────────────────────
class DeliveryFormScreen extends ConsumerStatefulWidget {
  const DeliveryFormScreen({super.key});

  @override
  ConsumerState<DeliveryFormScreen> createState() => _DeliveryFormScreenState();
}

class _DeliveryFormScreenState extends ConsumerState<DeliveryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _dateController = TextEditingController();
  final _birthWeightController = TextEditingController();
  final _apgarController = TextEditingController();
  final _complicationsController = TextEditingController();
  final _notesController = TextEditingController();
  String _deliveryMode = 'svd';
  String _birthOutcome = 'live_birth';
  String? _babySex;
  bool _isLoading = false;

  @override
  void dispose() {
    _patientController.dispose();
    _dateController.dispose();
    _birthWeightController.dispose();
    _apgarController.dispose();
    _complicationsController.dispose();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Delivery record saved')));
      ref.read(deliveryListProvider.notifier).load();
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
                      color: Color(0xFF10B981),
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
                  lastDate: DateTime.now(),
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

  Widget _dropdown(String label, String? value, Map<String, String> options,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value?.isEmpty == true ? null : value,
        decoration: InputDecoration(labelText: label),
        items: options.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Delivery Record')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _card('Patient & Date', [
                  _field(_patientController, 'Patient', Icons.person_search,
                      required: true),
                  _field(_dateController, 'Delivery Date', Icons.calendar_today,
                      required: true, isDate: true),
                ]),
                _card('Delivery Details', [
                  _dropdown('Mode of Delivery', _deliveryMode, {
                    'svd': 'Spontaneous Vaginal Delivery (SVD)',
                    'cs': 'Caesarean Section (CS)',
                    'assisted': 'Assisted Delivery',
                    'other': 'Other',
                  }, (v) => setState(() => _deliveryMode = v ?? 'svd')),
                  _dropdown('Birth Outcome', _birthOutcome, {
                    'live_birth': 'Live Birth',
                    'stillbirth': 'Stillbirth',
                    'abortion': 'Abortion/Miscarriage',
                  }, (v) => setState(() => _birthOutcome = v ?? 'live_birth')),
                ]),
                if (_birthOutcome == 'live_birth')
                  _card('Newborn Information', [
                    _dropdown('Baby\'s Sex', _babySex, {
                      'male': 'Male',
                      'female': 'Female',
                    }, (v) => setState(() => _babySex = v)),
                    _field(_birthWeightController, 'Birth Weight (kg)',
                        Icons.monitor_weight_outlined,
                        keyboardType: TextInputType.number),
                    _field(_apgarController, 'APGAR Score',
                        Icons.timer_outlined,
                        keyboardType: TextInputType.number),
                  ]),
                _card('Clinical Notes', [
                  _field(_complicationsController, 'Complications',
                      Icons.warning_amber_outlined,
                      maxLines: 2),
                  _field(_notesController, 'Notes', Icons.note_outlined,
                      maxLines: 3),
                ]),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Delivery Record',
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