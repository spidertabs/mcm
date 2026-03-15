// lib/core/providers/delivery_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/delivery_local_datasource.dart';
import '../../domain/entities/delivery_entity.dart';
import 'auth_provider.dart';

final deliveryListProvider =
    StateNotifierProvider<DeliveryListNotifier, DeliveryListState>((ref) {
  final ds = DeliveryLocalDataSource(ref.read(databaseHelperProvider));
  return DeliveryListNotifier(ds);
});

class DeliveryListState {
  final List<DeliveryEntity> deliveries;
  final bool isLoading;
  final String? error;

  const DeliveryListState({
    this.deliveries = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveryListState copyWith({
    List<DeliveryEntity>? deliveries,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      DeliveryListState(
        deliveries: deliveries ?? this.deliveries,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class DeliveryListNotifier extends StateNotifier<DeliveryListState> {
  final DeliveryLocalDataSource _ds;

  DeliveryListNotifier(this._ds) : super(const DeliveryListState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final deliveries = await _ds.getAllRecords();
      state = state.copyWith(isLoading: false, deliveries: deliveries);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}