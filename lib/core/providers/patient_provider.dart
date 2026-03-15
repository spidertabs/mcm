// lib/core/providers/patient_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/patient_local_datasource.dart';
import '../../data/repositories/patient_repository_impl.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/patient/create_patient_usecase.dart';
import '../../domain/usecases/patient/get_all_patients_usecase.dart';
import '../../domain/usecases/patient/get_patient_by_id_usecase.dart';
import 'auth_provider.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────
final patientDataSourceProvider = Provider<PatientLocalDataSource>(
    (ref) => PatientLocalDataSource(ref.read(databaseHelperProvider)));

final patientRepositoryProvider = Provider<PatientRepositoryImpl>(
    (ref) => PatientRepositoryImpl(ref.read(patientDataSourceProvider)));

// ── Use cases ─────────────────────────────────────────────────────────────────
final createPatientUseCaseProvider = Provider(
    (ref) => CreatePatientUseCase(ref.read(patientRepositoryProvider)));

final getAllPatientsUseCaseProvider = Provider(
    (ref) => GetAllPatientsUseCase(ref.read(patientRepositoryProvider)));

final getPatientByIdUseCaseProvider = Provider(
    (ref) => GetPatientByIdUseCase(ref.read(patientRepositoryProvider)));

// ── Single patient loader (for edit screen) ───────────────────────────────────
final patientByIdProvider =
    FutureProvider.family<PatientEntity?, String>((ref, id) async {
  final usecase = ref.read(getPatientByIdUseCaseProvider);
  final result = await usecase(id);
  return result.fold((_) => null, (p) => p);
});

// ── State ─────────────────────────────────────────────────────────────────────
class PatientListState {
  final List<PatientEntity> patients;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const PatientListState({
    this.patients = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  List<PatientEntity> get filtered {
    if (searchQuery.isEmpty) return patients;
    final q = searchQuery.toLowerCase();
    return patients
        .where((p) =>
            p.fullName.toLowerCase().contains(q) ||
            (p.phone?.contains(q) ?? false))
        .toList();
  }

  PatientListState copyWith({
    List<PatientEntity>? patients,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool clearError = false,
  }) =>
      PatientListState(
        patients: patients ?? this.patients,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        searchQuery: searchQuery ?? this.searchQuery,
      );
}

class PatientListNotifier extends StateNotifier<PatientListState> {
  final GetAllPatientsUseCase _getAll;
  final CreatePatientUseCase _create;
  final PatientRepositoryImpl _repo;

  PatientListNotifier(this._getAll, this._create, this._repo)
      : super(const PatientListState()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getAll();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (patients) =>
          state = state.copyWith(isLoading: false, patients: patients),
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> addPatient(PatientEntity patient) async {
    final result = await _create(patient);
    return result.fold(
      (f) {
        state = state.copyWith(error: f.message);
        return false;
      },
      (newPatient) {
        state = state.copyWith(
          patients: [newPatient, ...state.patients],
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> updatePatient(PatientEntity patient) async {
    final result = await _repo.updatePatient(patient);
    return result.fold(
      (f) {
        state = state.copyWith(error: f.message);
        return false;
      },
      (updated) {
        final updatedList = state.patients
            .map((p) => p.id == updated.id ? updated : p)
            .toList();
        state = state.copyWith(patients: updatedList, clearError: true);
        return true;
      },
    );
  }
}

final patientListProvider =
    StateNotifierProvider<PatientListNotifier, PatientListState>(
  (ref) => PatientListNotifier(
    ref.read(getAllPatientsUseCaseProvider),
    ref.read(createPatientUseCaseProvider),
    ref.read(patientRepositoryProvider),
  ),
);