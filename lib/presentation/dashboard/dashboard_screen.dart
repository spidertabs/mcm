// lib/presentation/dashboard/dashboard_screen.dart
// ignore_for_file: prefer_const_declarations, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../shared/app_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).currentUser;
    final stats = ref.watch(dashboardProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return AppScaffold(
      title: AppStrings.dashboard,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).load(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isWide
                  ? _WideLayout(user: user?.fullName ?? '', stats: stats)
                  : _NarrowLayout(user: user?.fullName ?? '', stats: stats),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Wide layout (desktop/web) ─────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final String user;
  final DashboardStats stats;
  const _WideLayout({required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _GreetingCard(userName: user)),
            const SizedBox(width: 16),
            Expanded(flex: 5, child: _StatsRow(stats: stats)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Quick Actions', onSeeAll: null),
                  _QuickActionsGrid(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                      title: AppStrings.recentAlerts,
                      onSeeAll: () => context.go(AppRoutes.anc)),
                  const _AlertsList(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionHeader(title: 'ANC Visits — This Month', onSeeAll: null),
        _AncTrendChart(trend: stats.ancTrend, isLoading: stats.isLoading),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Narrow layout (mobile) ────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final String user;
  final DashboardStats stats;
  const _NarrowLayout({required this.user, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GreetingCard(userName: user),
        const SizedBox(height: 16),
        _StatsRow(stats: stats),
        const SizedBox(height: 16),
        const _SectionHeader(title: 'Quick Actions', onSeeAll: null),
        const _QuickActionsGrid(),
        const SizedBox(height: 16),
        _SectionHeader(title: AppStrings.recentAlerts,
            onSeeAll: () => context.go(AppRoutes.anc)),
        const _AlertsList(),
        const SizedBox(height: 16),
        const _SectionHeader(title: 'ANC Visits — This Month', onSeeAll: null),
        _AncTrendChart(trend: stats.ancTrend, isLoading: stats.isLoading),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Greeting card ─────────────────────────────────────────────────────────────
class _GreetingCard extends StatelessWidget {
  final String userName;
  const _GreetingCard({required this.userName});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _todayLabel {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A1580), Color(0xFF7B2FBE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A1580).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$_greeting,',
              style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            userName.split(' ').first,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 12, color: Colors.white54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Rubare Town Council  ·  $_todayLabel',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, size: 11, color: Colors.white70),
                SizedBox(width: 5),
                Text('MaternalCare Monitor',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row — compact horizontal cards ──────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final DashboardStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        AppStrings.totalPatients,
        stats.isLoading ? '...' : '${stats.totalPatients}',
        Icons.people_alt_outlined,
        const Color(0xFF0EA5E9),
        const Color(0xFFE0F2FE),
      ),
      (
        AppStrings.ancVisitsThisMonth,
        stats.isLoading ? '...' : '${stats.ancVisitsThisMonth}',
        Icons.pregnant_woman_outlined,
        const Color(0xFF8B5CF6),
        const Color(0xFFEDE9FE),
      ),
      (
        AppStrings.deliveriesThisMonth,
        stats.isLoading ? '...' : '${stats.deliveriesThisMonth}',
        Icons.local_hospital_outlined,
        const Color(0xFF10B981),
        const Color(0xFFD1FAE5),
      ),
      (
        AppStrings.highRiskCases,
        stats.isLoading ? '...' : '${stats.highRiskCount}',
        Icons.warning_amber_outlined,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 420;
      if (isNarrow) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatTile(item: items[0])),
                const SizedBox(width: 8),
                Expanded(child: _StatTile(item: items[1])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _StatTile(item: items[2])),
                const SizedBox(width: 8),
                Expanded(child: _StatTile(item: items[3])),
              ],
            ),
          ],
        );
      }
      return Row(
        children: items.asMap().entries.map((e) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
              child: _StatTile(item: e.value),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final (String, String, IconData, Color, Color) item;
  const _StatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final (label, value, icon, accent, bg) = item;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accent,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Quick actions grid ────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.person_add_outlined, 'New Patient', 'Register patient',
          AppRoutes.patientNew, const Color(0xFF0EA5E9)),
      (Icons.pregnant_woman_outlined, 'ANC Visit', 'Record visit',
          AppRoutes.ancNew, const Color(0xFF8B5CF6)),
      (Icons.local_hospital_outlined, 'Delivery', 'Log delivery',
          AppRoutes.deliveryNew, const Color(0xFF10B981)),
      (Icons.child_care_outlined, 'Postnatal', 'Post-delivery',
          AppRoutes.postnatalNew, const Color(0xFFF59E0B)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: actions
          .map((a) => _ActionCard(
                icon: a.$1,
                title: a.$2,
                subtitle: a.$3,
                route: a.$4,
                color: a.$5,
              ))
          .toList(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: const Color(0xFFF1F5F9), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B))),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 14, color: color.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Alerts list ───────────────────────────────────────────────────────────────
class _AlertsList extends StatelessWidget {
  const _AlertsList();

  static const _alerts = [
    ('Apio Grace missed ANC visit 3 days ago', 'high', 'ANC'),
    ('Akello Betty BP 148/95 — requires follow-up', 'medium', 'BP'),
    ('2 patients due for postnatal visit this week', 'low', 'PNC'),
    ('Namukasa Rose EDD in 7 days — ANC 4 not recorded', 'medium', 'EDD'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _alerts.asMap().entries.map((e) {
          final isLast = e.key == _alerts.length - 1;
          final (msg, priority, tag) = e.value;
          final accent = priority == 'high'
              ? const Color(0xFFEF4444)
              : priority == 'medium'
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF3B82F6);
          final bg = priority == 'high'
              ? const Color(0xFFFEF2F2)
              : priority == 'medium'
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFEFF6FF);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: accent.withValues(alpha: 0.25)),
                      ),
                      child: Text(tag,
                          style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(msg,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: accent, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── ANC Trend Chart — real bar chart from DB data ─────────────────────────────
class _AncTrendChart extends StatelessWidget {
  final List<AncTrendPoint> trend;
  final bool isLoading;
  const _AncTrendChart({required this.trend, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : trend.isEmpty || trend.every((p) => p.count == 0)
              ? _emptyChart()
              : _barChart(),
    );
  }

  Widget _emptyChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart_rounded,
              size: 26, color: Color(0xFF8B5CF6)),
        ),
        const SizedBox(height: 8),
        const Text('No ANC visits recorded this month',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B))),
        const SizedBox(height: 3),
        const Text('Visits will appear here as they are recorded',
            style: TextStyle(fontSize: 10, color: Color(0xFFCBD5E1))),
      ],
    );
  }

  Widget _barChart() {
    final maxCount =
        trend.map((p) => p.count).reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().day;

    // Show at most every 5th day label to avoid crowding
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y-axis label
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Visits',
                style: TextStyle(fontSize: 9, color: Color(0xFFCBD5E1))),
            Text('${trend.where((p) => p.count > 0).length} days with visits',
                style: const TextStyle(
                    fontSize: 9, color: Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 4),
        // Bars
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            // Only show days up to today
            final days = trend.where((p) => p.day <= today).toList();
            if (days.isEmpty) return _emptyChart();
            final barWidth =
                (constraints.maxWidth / days.length).clamp(4.0, 24.0);

            final labelHeight = 14.0;
            final countLabelHeight = 12.0;
            final availableBarHeight = constraints.maxHeight
                - labelHeight
                - countLabelHeight
                - 6; // spacing

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((point) {
                final isToday = point.day == today;
                final fraction =
                    maxCount == 0 ? 0.0 : point.count / maxCount;
                final barH =
                    (fraction * availableBarHeight).clamp(
                        point.count > 0 ? 4.0 : 1.5,
                        availableBarHeight);
                final color = point.count == 0
                    ? const Color(0xFFF1F5F9)
                    : isToday
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFBBF7D0);
                final labelColor = isToday
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFFCBD5E1);

                final showLabel =
                    point.day % 5 == 0 || isToday || point.day == 1;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: countLabelHeight,
                          child: point.count > 0 && barWidth >= 12
                              ? Text(
                                  '${point.count}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: isToday
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w700),
                                )
                              : null,
                        ),
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                            border: isToday
                                ? Border.all(
                                    color: const Color(0xFF8B5CF6),
                                    width: 1)
                                : null,
                          ),
                        ),
                        SizedBox(
                          height: labelHeight,
                          child: showLabel
                              ? Text(
                                  '${point.day}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 7,
                                      color: labelColor,
                                      fontWeight: isToday
                                          ? FontWeight.w700
                                          : FontWeight.normal),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ),
        const SizedBox(height: 2),
        // Legend
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: const Color(0xFFBBF7D0),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            const Text('Visit recorded',
                style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
            const SizedBox(width: 12),
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            const Text('Today',
                style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.1)),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('See all',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}