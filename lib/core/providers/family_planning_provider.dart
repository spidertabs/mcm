// lib/core/providers/family_planning_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/family_planning_local_datasource.dart';
import '../../domain/entities/family_planning_entity.dart';
import 'auth_provider.dart';

final familyPlanningListProvider =
    StateNotifierProvider<FamilyPlanningNotifier, FamilyPlanningState>(
        (ref) {
  final ds =
      FamilyPlanningLocalDataSource(ref.read(databaseHelperProvider));
  return FamilyPlanningNotifier(ds);
});

class FamilyPlanningState {
  final List<FamilyPlanningEntity> records;
  final Map<String, int> methodCounts;
  final bool isLoading;
  final String? error;

  const FamilyPlanningState({
    this.records = const [],
    this.methodCounts = const {},
    this.isLoading = false,
    this.error,
  });

  FamilyPlanningState copyWith({
    List<FamilyPlanningEntity>? records,
    Map<String, int>? methodCounts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      FamilyPlanningState(
        records: records ?? this.records,
        methodCounts: methodCounts ?? this.methodCounts,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class FamilyPlanningNotifier extends StateNotifier<FamilyPlanningState> {
  final FamilyPlanningLocalDataSource _ds;

  FamilyPlanningNotifier(this._ds)
      : super(const FamilyPlanningState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final records = await _ds.getAllRecords();
      final counts = await _ds.countByMethodThisMonth();
      state = state.copyWith(
          isLoading: false, records: records, methodCounts: counts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}