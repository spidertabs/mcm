// lib/core/providers/postnatal_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/postnatal_local_datasource.dart';
import '../../domain/entities/postnatal_entity.dart';
import 'auth_provider.dart';

final postnatalListProvider =
    StateNotifierProvider<PostnatalListNotifier, PostnatalListState>((ref) {
  final ds = PostnatalLocalDataSource(ref.read(databaseHelperProvider));
  return PostnatalListNotifier(ds);
});

class PostnatalListState {
  final List<PostnatalEntity> records;
  final bool isLoading;
  final String? error;

  const PostnatalListState({
    this.records = const [],
    this.isLoading = false,
    this.error,
  });

  PostnatalListState copyWith({
    List<PostnatalEntity>? records,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      PostnatalListState(
        records: records ?? this.records,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );

  List<PostnatalEntity> get dueToday {
    final today = DateTime.now();
    return records.where((r) {
      return r.visitDate.year == today.year &&
          r.visitDate.month == today.month &&
          r.visitDate.day == today.day;
    }).toList();
  }
}

class PostnatalListNotifier extends StateNotifier<PostnatalListState> {
  final PostnatalLocalDataSource _ds;

  PostnatalListNotifier(this._ds) : super(const PostnatalListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final records = await _ds.getAllRecords();
      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}