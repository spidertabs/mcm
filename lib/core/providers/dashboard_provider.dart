// lib/core/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/anc_local_datasource.dart';
import '../../data/datasources/local/delivery_local_datasource.dart';
import '../../domain/entities/patient_entity.dart';
import 'auth_provider.dart';
import 'patient_provider.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────
final ancDataSourceProvider = Provider<AncLocalDataSource>(
        (ref) => AncLocalDataSource(ref.read(databaseHelperProvider)));

final deliveryDataSourceProvider = Provider<DeliveryLocalDataSource>(
        (ref) => DeliveryLocalDataSource(ref.read(databaseHelperProvider)));

// ── ANC trend point — one per day of the current month ───────────────────────
class AncTrendPoint {
  final int day;   // day of month 1–31
  final int count; // visits on that day
  const AncTrendPoint(this.day, this.count);
}

// ── Dashboard stats ───────────────────────────────────────────────────────────
class DashboardStats {
  final int totalPatients;
  final int ancVisitsThisMonth;
  final int deliveriesThisMonth;
  final int highRiskCount;
  final List<AncTrendPoint> ancTrend; // per-day counts this month
  final bool isLoading;
  final String? error;

  const DashboardStats({
    this.totalPatients = 0,
    this.ancVisitsThisMonth = 0,
    this.deliveriesThisMonth = 0,
    this.highRiskCount = 0,
    this.ancTrend = const [],
    this.isLoading = false,
    this.error,
  });

  DashboardStats copyWith({
    int? totalPatients,
    int? ancVisitsThisMonth,
    int? deliveriesThisMonth,
    int? highRiskCount,
    List<AncTrendPoint>? ancTrend,
    bool? isLoading,
    String? error,
  }) =>
      DashboardStats(
        totalPatients: totalPatients ?? this.totalPatients,
        ancVisitsThisMonth: ancVisitsThisMonth ?? this.ancVisitsThisMonth,
        deliveriesThisMonth: deliveriesThisMonth ?? this.deliveriesThisMonth,
        highRiskCount: highRiskCount ?? this.highRiskCount,
        ancTrend: ancTrend ?? this.ancTrend,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class DashboardNotifier extends StateNotifier<DashboardStats> {
  final AncLocalDataSource _ancDs;
  final DeliveryLocalDataSource _deliveryDs;
  final PatientListNotifier _patientNotifier;

  DashboardNotifier(this._ancDs, this._deliveryDs, this._patientNotifier)
      : super(const DashboardStats(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final now = DateTime.now();

      // Parallel fetches
      final ancCount = await _ancDs.countThisMonth();
      final deliveryCount = await _deliveryDs.countThisMonth();
      await _patientNotifier.loadPatients();

      final patients = _patientNotifier.state.patients;
      final highRisk = patients
          .where((p) => p.riskLevel == RiskLevel.high || p.gravida >= 4)
          .length;

      // Build per-day trend for current month
      final allVisits = await _ancDs.getAllVisits();
      final daysInMonth =
          DateTime(now.year, now.month + 1, 0).day; // e.g. 31

      // Count visits per day
      final dayCounts = <int, int>{};
      for (final v in allVisits) {
        if (v.visitDate.year == now.year &&
            v.visitDate.month == now.month) {
          final d = v.visitDate.day;
          dayCounts[d] = (dayCounts[d] ?? 0) + 1;
        }
      }

      // Build list for every day 1..daysInMonth (0 if no visits)
      final trend = List.generate(
        daysInMonth,
            (i) => AncTrendPoint(i + 1, dayCounts[i + 1] ?? 0),
      );

      state = DashboardStats(
        totalPatients: patients.length,
        ancVisitsThisMonth: ancCount,
        deliveriesThisMonth: deliveryCount,
        highRiskCount: highRisk,
        ancTrend: trend,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider =
StateNotifierProvider<DashboardNotifier, DashboardStats>(
      (ref) => DashboardNotifier(
    ref.read(ancDataSourceProvider),
    ref.read(deliveryDataSourceProvider),
    ref.read(patientListProvider.notifier),
  ),
);