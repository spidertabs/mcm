// lib/presentation/shared/app_scaffold.dart
// ignore_for_file: unused_local_variable, prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import 'page_layout.dart';

// Show permanent sidebar when width >= this
const double _kSidebarBreakpoint = 720;
const double _kSidebarWidth = 220.0;

// Content background — light grey-blue
const Color _kContentBg = Color(0xFFF8F7FC);

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= _kSidebarBreakpoint;

    if (isWide) {
      // ── Desktop / Web — permanent sidebar ──────────────────────────────────
      return Scaffold(
        backgroundColor: _kContentBg,
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            const _Sidebar(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(title: title, actions: actions),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ── Mobile — drawer ───────────────────────────────────────────────────────
    return Scaffold(
      backgroundColor: _kContentBg,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const _MobileDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}

// ── Top bar (desktop/web only) ────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  const _TopBar({required this.title, this.actions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).currentUser;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8E4F0), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D1B69),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDF6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar — shows photo if set, initials otherwise
                _buildAvatar(user?.avatarPath, user?.fullName ?? ''),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName.split(' ').first ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D1B69)),
                    ),
                    Text(
                      user?.role.label ?? '',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarPath, String fullName) {
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    if (avatarPath == null) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.primary,
        child: Text(initial,
            style: const TextStyle(
                color: Colors.white, fontSize: 12,
                fontWeight: FontWeight.bold)),
      );
    }
    return SizedBox(
      width: 28, height: 28,
      child: ClipOval(
        child: PlatformAvatarImage(
          path: avatarPath,
          size: 28,
          fallbackInitial: initial,
          fallbackColor: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Permanent sidebar ─────────────────────────────────────────────────────────
class _Sidebar extends ConsumerWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).currentUser;
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      width: _kSidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF2D1B69),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 16,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'MCM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: AppStrings.dashboard,
                  route: AppRoutes.dashboard,
                  currentLocation: location,
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: AppStrings.patients,
                  route: AppRoutes.patients,
                  currentLocation: location,
                ),
                const _SidebarSection(label: 'SERVICES'),
                _SidebarItem(
                  icon: Icons.pregnant_woman_outlined,
                  activeIcon: Icons.pregnant_woman,
                  label: AppStrings.anc,
                  route: AppRoutes.anc,
                  currentLocation: location,
                ),
                _SidebarItem(
                  icon: Icons.local_hospital_outlined,
                  activeIcon: Icons.local_hospital,
                  label: AppStrings.delivery,
                  route: AppRoutes.delivery,
                  currentLocation: location,
                ),
                _SidebarItem(
                  icon: Icons.child_care_outlined,
                  activeIcon: Icons.child_care,
                  label: AppStrings.postnatal,
                  route: AppRoutes.postnatal,
                  currentLocation: location,
                ),
                _SidebarItem(
                  icon: Icons.health_and_safety_outlined,
                  activeIcon: Icons.health_and_safety,
                  label: AppStrings.familyPlanning,
                  route: AppRoutes.familyPlanning,
                  currentLocation: location,
                ),
                const _SidebarSection(label: 'SYSTEM'),
                _SidebarItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: AppStrings.reports,
                  route: AppRoutes.reports,
                  currentLocation: location,
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: AppStrings.settings,
                  route: AppRoutes.settings,
                  currentLocation: location,
                ),
              ],
            ),
          ),

          // Logout
          Container(
            margin: const EdgeInsets.all(10),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logout();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.logout,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.6)),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.logout,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  final String label;
  const _SidebarSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentLocation;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  bool get _selected => currentLocation == route;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: _selected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 9),
            child: Row(
              children: [
                if (_selected)
                  Container(
                    width: 3,
                    height: 16,
                    margin: const EdgeInsets.only(right: 9),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(width: 12),
                Icon(
                  _selected ? activeIcon : icon,
                  size: 18,
                  color: _selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                      fontWeight: _selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mobile drawer ─────────────────────────────────────────────────────────────
class _MobileDrawer extends ConsumerWidget {
  const _MobileDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(user?.fullName ?? ''),
            accountEmail: Text(user?.role.label ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: user?.avatarPath != null
                    ? PlatformAvatarImage(
                        path: user!.avatarPath!,
                        size: 72,
                        fallbackInitial: user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        fallbackColor: AppColors.primary,
                      )
                    : Text(
                        user?.fullName.isNotEmpty == true
                            ? user!.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(Icons.dashboard, AppStrings.dashboard, AppRoutes.dashboard),
                _DrawerItem(Icons.people, AppStrings.patients, AppRoutes.patients),
                const Divider(),
                _DrawerItem(Icons.pregnant_woman, AppStrings.anc, AppRoutes.anc),
                _DrawerItem(Icons.local_hospital, AppStrings.delivery, AppRoutes.delivery),
                _DrawerItem(Icons.child_care, AppStrings.postnatal, AppRoutes.postnatal),
                _DrawerItem(Icons.health_and_safety, AppStrings.familyPlanning, AppRoutes.familyPlanning),
                const Divider(),
                _DrawerItem(Icons.bar_chart, AppStrings.reports, AppRoutes.reports),
                _DrawerItem(Icons.settings, AppStrings.settings, AppRoutes.settings),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(AppStrings.logout,
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _DrawerItem(this.icon, this.label, this.route);

  @override
  Widget build(BuildContext context) {
    final selected = GoRouterState.of(context).matchedLocation == route;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : null),
      title: Text(label,
          style: selected
              ? const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold)
              : null),
      selected: selected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}