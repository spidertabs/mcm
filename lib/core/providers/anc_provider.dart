// lib/core/providers/anc_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/anc_local_datasource.dart';
import '../../domain/entities/anc_visit_entity.dart';
import 'auth_provider.dart';

final ancListProvider =
    StateNotifierProvider<AncListNotifier, AncListState>((ref) {
  final ds = AncLocalDataSource(ref.read(databaseHelperProvider));
  return AncListNotifier(ds);
});

class AncListState {
  final List<AncVisitEntity> visits;
  final bool isLoading;
  final String? error;

  const AncListState({
    this.visits = const [],
    this.isLoading = false,
    this.error,
  });

  AncListState copyWith({
    List<AncVisitEntity>? visits,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      AncListState(
        visits: visits ?? this.visits,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class AncListNotifier extends StateNotifier<AncListState> {
  final AncLocalDataSource _ds;

  AncListNotifier(this._ds) : super(const AncListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final visits = await _ds.getAllVisits();
      state = state.copyWith(isLoading: false, visits: visits);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Count for summary bar
  int get thisMonthCount {
    final now = DateTime.now();
    return state.visits
        .where((v) =>
            v.visitDate.year == now.year && v.visitDate.month == now.month)
        .length;
  }

  int get firstVisitCount =>
      state.visits.where((v) => v.visitNumber == 1).length;

  int get fourPlusVisitPatients {
    final map = <String, int>{};
    for (final v in state.visits) {
      map[v.patientId] = (map[v.patientId] ?? 0) + 1;
    }
    return map.values.where((c) => c >= 4).length;
  }
}