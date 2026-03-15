// lib/presentation/patients/patients_screen.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/patient_provider.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/patient_entity.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

enum _PatientFilter { all, highRisk, ancDue, postnatal }

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final _searchController = TextEditingController();
  _PatientFilter _filter = _PatientFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PatientEntity> _applyFilter(List<PatientEntity> patients) {
    switch (_filter) {
      case _PatientFilter.highRisk:
        return patients
            .where((p) => p.riskLevel == RiskLevel.high || (p.gravida >= 4))
            .toList();
      case _PatientFilter.ancDue:
        // patients with EDD in the future (still pregnant)
        return patients
            .where((p) =>
                p.edd != null && p.edd!.isAfter(DateTime.now()))
            .toList();
      case _PatientFilter.postnatal:
        // patients whose EDD has passed within last 42 days
        return patients.where((p) {
          if (p.edd == null) return false;
          final daysSince = DateTime.now().difference(p.edd!).inDays;
          return daysSince >= 0 && daysSince <= 42;
        }).toList();
      case _PatientFilter.all:
        return patients;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientListProvider);
    final filtered = _applyFilter(state.filtered);

    return AppScaffold(
      title: AppStrings.patients,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.patientNew),
        icon: const Icon(Icons.person_add),
        label: const Text('New Patient'),
      ),
      body: Column(
        children: [
          // Search + filters in constrained header
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or phone…',
                          hintStyle: const TextStyle(
                              fontSize: 13, color: Color(0xFFCBD5E1)),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFFCBD5E1), size: 20),
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 16, color: Color(0xFFCBD5E1)),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(patientListProvider.notifier)
                                        .search('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onChanged: (v) =>
                            ref.read(patientListProvider.notifier).search(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    Row(
                      children: [
                        _buildChip('All', _PatientFilter.all),
                        const SizedBox(width: 6),
                        _buildChip('High Risk', _PatientFilter.highRisk),
                        const SizedBox(width: 6),
                        _buildChip('ANC Due', _PatientFilter.ancDue),
                        const SizedBox(width: 6),
                        _buildChip('Postnatal', _PatientFilter.postnatal),
                        const Spacer(),
                        if (!state.isLoading)
                          Text(
                            '${filtered.length} patient${filtered.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? ErrorState(
                        message: state.error!,
                        onRetry: () => ref
                            .read(patientListProvider.notifier)
                            .loadPatients(),
                      )
                    : filtered.isEmpty
                        ? EmptyState(
                            icon: state.searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.people_outline,
                            title: state.searchQuery.isNotEmpty
                                ? 'No patients match your search'
                                : 'No patients registered yet',
                            subtitle: state.searchQuery.isEmpty
                                ? 'Tap + to register the first patient'
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(patientListProvider.notifier)
                                .loadPatients(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              itemCount: filtered.length + 1,
                              itemBuilder: (context, i) {
                                if (i == 0) {
                                  // Centering wrapper
                                  return const SizedBox.shrink();
                                }
                                return Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                        maxWidth: 960),
                                    child: _PatientTile(
                                        patient: filtered[i - 1]),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, _PatientFilter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF8B5CF6)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF8B5CF6)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

// ── Patient tile ──────────────────────────────────────────────────────────────
class _PatientTile extends StatelessWidget {
  final PatientEntity patient;
  const _PatientTile({required this.patient});

  String get _initials {
    final parts = patient.fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return patient.fullName.substring(0, 2).toUpperCase();
  }

  String get _ageLabel {
    final age = DateTime.now().difference(patient.dateOfBirth).inDays ~/ 365;
    return '$age yrs';
  }

  String? get _eddLabel {
    final edd = patient.edd;
    if (edd == null) return null;
    return 'EDD ${edd.day.toString().padLeft(2, '0')}/'
        '${edd.month.toString().padLeft(2, '0')}/${edd.year}';
  }

  bool get _isHighRisk =>
      patient.riskLevel == RiskLevel.high || (patient.gravida) >= 4;

  // Unique color per initials
  Color get _avatarColor {
    const colors = [
      Color(0xFF8B5CF6), Color(0xFF0EA5E9), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFF6366F1),
    ];
    return colors[patient.fullName.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;
    final bg = color.withValues(alpha: 0.1);

    return RecordCard(
      onTap: () => context.push('${AppRoutes.patients}/${patient.id}'),
      leading: RecordAvatar(initials: _initials, color: color, bg: bg),
      title: Text(
        patient.fullName,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        [_ageLabel, _eddLabel, patient.village ?? patient.address]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join('  ·  '),
        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isHighRisk)
            StatusChip(
              label: 'High Risk',
              color: const Color(0xFFEF4444),
              bg: const Color(0xFFFEF2F2),
            ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}

// ── Empty / error states ──────────────────────────────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
// Patient Form Screen — create & edit
// ══════════════════════════════════════════════════════════════════════════════
class PatientFormScreen extends ConsumerStatefulWidget {
  final String? patientId;
  const PatientFormScreen({super.key, this.patientId});

  @override
  ConsumerState<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends ConsumerState<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _nokController = TextEditingController();
  final _nokPhoneController = TextEditingController();
  final _lmpController = TextEditingController();

  DateTime? _dobDate;
  DateTime? _lmpDate;
  bool _isLoading = false;
  bool _prefilled = false;

  // Snapshot of original values for dirty detection
  Map<String, String> _original = {};

  bool get _isEditing => widget.patientId != null;

  bool get _isDirty {
    if (!_isEditing) return true; // new patient — always enable
    return _fullNameController.text != _original['fullName'] ||
        _dobController.text != _original['dob'] ||
        _phoneController.text != _original['phone'] ||
        _addressController.text != _original['address'] ||
        _nokController.text != _original['nok'] ||
        _nokPhoneController.text != _original['nokPhone'] ||
        _lmpController.text != _original['lmp'];
  }

  @override
  void initState() {
    super.initState();
    // Listen for changes to rebuild the save button state
    for (final c in [
      _fullNameController,
      _dobController,
      _phoneController,
      _addressController,
      _nokController,
      _nokPhoneController,
      _lmpController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _nokController.dispose();
    _nokPhoneController.dispose();
    _lmpController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  DateTime? _calcEdd(DateTime? lmp) => lmp?.add(const Duration(days: 280));

  void _prefillFromPatient(PatientEntity p) {
    if (_prefilled) return;
    _prefilled = true;

    _fullNameController.text = p.fullName;
    _dobController.text = _formatDate(p.dateOfBirth);
    _dobDate = p.dateOfBirth;
    _phoneController.text = p.phone ?? '';
    _addressController.text = p.address ?? '';
    _nokController.text = p.nextOfKin ?? '';
    _nokPhoneController.text = p.nokPhone ?? '';
    if (p.lmp != null) {
      _lmpController.text = _formatDate(p.lmp!);
      _lmpDate = p.lmp;
    }

    // Save snapshot for dirty detection
    _original = {
      'fullName': _fullNameController.text,
      'dob': _dobController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'nok': _nokController.text,
      'nokPhone': _nokPhoneController.text,
      'lmp': _lmpController.text,
    };
  }

  Future<void> _pickDate(
    TextEditingController ctrl,
    DateTime first,
    DateTime last,
    Function(DateTime) onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      ctrl.text = _formatDate(picked);
      onPicked(picked);
    }
  }

  Future<void> _submit(PatientEntity? existing) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final notifier = ref.read(patientListProvider.notifier);

    final patient = PatientEntity(
      id: existing?.id,
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _dobDate ?? existing?.dateOfBirth ?? DateTime(2000),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      village: existing?.village,
      nextOfKin: _nokController.text.trim().isEmpty
          ? null
          : _nokController.text.trim(),
      nokPhone: _nokPhoneController.text.trim().isEmpty
          ? null
          : _nokPhoneController.text.trim(),
      lmp: _lmpDate ?? existing?.lmp,
      edd: _calcEdd(_lmpDate ?? existing?.lmp),
      gravida: existing?.gravida ?? 0,
      parity: existing?.parity ?? 0,
      bloodGroup: existing?.bloodGroup,
      riskLevel: existing?.riskLevel ?? RiskLevel.low,
      registeredBy: existing?.registeredBy ?? '',
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    final success = _isEditing
        ? await notifier.updatePatient(patient)
        : await notifier.addPatient(patient);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? 'Patient updated' : AppStrings.patientAdded),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                ref.read(patientListProvider).error ?? 'Failed to save'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // When editing, watch the patient data and prefill
    final patientAsync = _isEditing
        ? ref.watch(patientByIdProvider(widget.patientId!))
        : null;

    if (_isEditing && patientAsync != null) {
      patientAsync.whenData((p) {
        if (p != null) _prefillFromPatient(p);
      });
    }

    final existing = _isEditing
        ? patientAsync?.asData?.value
        : null;

    final isLoadingPatient =
        _isEditing && (patientAsync?.isLoading ?? true) && !_prefilled;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Patient' : AppStrings.addPatient),
      ),
      body: isLoadingPatient
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                children: [
                  _FormSection(
                    title: 'Personal Information',
                    children: [
                      _buildField(
                        _fullNameController,
                        AppStrings.fullName,
                        Icons.person_outline,
                        required: true,
                        capitalization: TextCapitalization.words,
                      ),
                      _buildField(
                        _dobController,
                        AppStrings.dateOfBirth,
                        Icons.cake_outlined,
                        required: true,
                        isDate: true,
                        onDatePicked: (d) => setState(() => _dobDate = d),
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                      ),
                      _buildField(
                        _phoneController,
                        AppStrings.contactNumber,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: AppValidators.phone,
                      ),
                      _buildField(
                        _addressController,
                        AppStrings.address,
                        Icons.home_outlined,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  _FormSection(
                    title: 'Next of Kin',
                    children: [
                      _buildField(
                        _nokController,
                        AppStrings.nextOfKin,
                        Icons.people_outline,
                        capitalization: TextCapitalization.words,
                      ),
                      _buildField(
                        _nokPhoneController,
                        'Next of Kin Phone',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: AppValidators.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  _FormSection(
                    title: 'Obstetric Information',
                    children: [
                      _buildField(
                        _lmpController,
                        AppStrings.lmpDate,
                        Icons.calendar_today,
                        isDate: true,
                        onDatePicked: (d) => setState(() => _lmpDate = d),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      ),
                      if (_lmpDate != null ||
                          (existing?.lmp != null && _lmpController.text.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.sm),
                          child: Text(
                            'EDD: ${_formatDate(_calcEdd(_lmpDate ?? existing?.lmp)!)}',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xl),
                  ElevatedButton(
                    // Disabled when editing and no changes made
                    onPressed: (_isLoading || (_isEditing && !_isDirty))
                        ? null
                        : () => _submit(existing),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_isEditing ? 'Save Changes' : 'Register Patient'),
                  ),
                  if (_isEditing && !_isDirty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSizes.xs),
                      child: Center(
                        child: Text(
                          'No changes made',
                          style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: AppSizes.fontSm),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool isDate = false,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    int maxLines = 1,
    String? Function(String?)? validator,
    Function(DateTime)? onDatePicked,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        maxLines: maxLines,
        readOnly: isDate,
        onTap: isDate
            ? () => _pickDate(
                  controller,
                  firstDate ?? DateTime(1920),
                  lastDate ?? DateTime.now().add(const Duration(days: 365)),
                  onDatePicked ?? (_) {},
                )
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon),
          suffixIcon: isDate ? const Icon(Icons.calendar_today) : null,
        ),
        validator: validator ??
            (required
                ? (v) =>
                    (v == null || v.isEmpty) ? '$label is required' : null
                : null),
        enabled: !_isLoading,
      ),
    );
  }
}

// ── Form section ──────────────────────────────────────────────────────────────
class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            ...children,
          ],
        ),
      ),
    );
  }
}