// lib/presentation/settings/settings_screen.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/storage/database_helper.dart';
import '../shared/app_scaffold.dart';
import '../shared/page_layout.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).currentUser;

    return AppScaffold(
      title: AppStrings.settings,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                _ProfileCard(
                  name: user?.fullName ?? '',
                  role: user?.role.label ?? '',
                  username: user?.username ?? '',
                  avatarPath: user?.avatarPath,
                ),
                const SizedBox(height: 20),

                // Account section
                _SettingsSection(
                  label: 'Account',
                  items: [
                    _SettingsItem(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () => _showChangePassword(context, ref),
                    ),
                    if (user?.isAdmin == true)
                      _SettingsItem(
                        icon: Icons.people_outline,
                        title: 'Manage Users',
                        subtitle: 'View and manage system users',
                        onTap: () => _showManageUsers(context),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // App section
                _SettingsSection(
                  label: 'Application',
                  items: [
                    _SettingsItem(
                      icon: Icons.business_outlined,
                      title: 'Facility Information',
                      subtitle: 'Rubare Town Council Health Centre',
                      onTap: () => _showFacility(context),
                    ),
                    _SettingsItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Appearance',
                      subtitle: 'Follows device theme setting',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Theme follows your device setting'))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Data section
                _SettingsSection(
                  label: 'Data',
                  items: [
                    _SettingsItem(
                      icon: Icons.backup_outlined,
                      title: 'Backup Data',
                      subtitle: 'Export all records to a JSON file',
                      onTap: () => _exportBackup(context),
                    ),
                    _SettingsItem(
                      icon: Icons.storage_outlined,
                      title: 'Database Info',
                      subtitle: 'View record counts and storage info',
                      onTap: () => _showDbInfo(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // About section
                _SettingsSection(
                  label: 'About',
                  items: [
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: 'About MaternalCare Monitor',
                      subtitle: 'Version 1.0.0',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: AppStrings.appName,
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '2025-2026 Rubare Town Council\nFinal Year Project',
                        children: const [
                          SizedBox(height: 16),
                          Text(AppStrings.appTagline),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout,
                        color: Color(0xFFEF4444), size: 16),
                    label: const Text(AppStrings.logout,
                        style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFFEF4444), width: 1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context, WidgetRef ref) {
    showDialog(context: context,
        builder: (_) => _ChangePasswordDialog(ref: ref));
  }

  void _showManageUsers(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users', orderBy: 'full_name ASC');
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('System Users'),
        content: SizedBox(
          width: 420,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (_, i) {
              final u = users[i];
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFEDE9FE),
                  child: Text((u['full_name'] as String)[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                title: Text(u['full_name'] as String,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('@${u['username']}  ·  ${u['role']}',
                    style: const TextStyle(fontSize: 11)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (u['is_active'] as int) == 1
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (u['is_active'] as int) == 1 ? 'Active' : 'Inactive',
                    style: TextStyle(
                        fontSize: 10,
                        color: (u['is_active'] as int) == 1
                            ? const Color(0xFF059669)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showFacility(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Facility Information'),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          _InfoRow(label: 'Facility', value: 'Rubare Town Council H/C'),
          _InfoRow(label: 'District', value: 'Rukungiri'),
          _InfoRow(label: 'Region', value: 'Western Uganda'),
          _InfoRow(label: 'System', value: AppStrings.appName),
          _InfoRow(label: 'Version', value: '1.0.0'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _showDbInfo(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    final counts = await Future.wait([
      db.rawQuery('SELECT COUNT(*) as c FROM patients'),
      db.rawQuery('SELECT COUNT(*) as c FROM anc_visits'),
      db.rawQuery('SELECT COUNT(*) as c FROM delivery_records'),
      db.rawQuery('SELECT COUNT(*) as c FROM postnatal_records'),
      db.rawQuery('SELECT COUNT(*) as c FROM family_planning'),
      db.rawQuery('SELECT COUNT(*) as c FROM users'),
    ]);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Database Information'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _InfoRow(label: 'Patients', value: '${counts[0].first['c']}'),
          _InfoRow(label: 'ANC Visits', value: '${counts[1].first['c']}'),
          _InfoRow(label: 'Deliveries', value: '${counts[2].first['c']}'),
          _InfoRow(label: 'Postnatal', value: '${counts[3].first['c']}'),
          _InfoRow(label: 'Family Planning', value: '${counts[4].first['c']}'),
          _InfoRow(label: 'Users', value: '${counts[5].first['c']}'),
          const Divider(),
          const _InfoRow(label: 'Storage', value: 'On-device SQLite'),
          const _InfoRow(label: 'DB Version', value: '4'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Exporting…'),
        ]),
      ),
    );
    try {
      final db = await DatabaseHelper.instance.database;
      final backup = <String, dynamic>{};
      for (final t in ['patients', 'anc_visits', 'delivery_records', 'postnatal_records', 'family_planning']) {
        backup[t] = await db.query(t);
      }
      backup['exported_at'] = DateTime.now().toIso8601String();
      final json = const JsonEncoder.withIndent('  ').convert(backup);
      if (context.mounted) Navigator.pop(context);
      await Printing.sharePdf(
        bytes: Uint8List.fromList(utf8.encode(json)),
        filename: 'mcm_backup_${DateTime.now().toIso8601String().substring(0, 10)}.json',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup failed: $e'), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) await ref.read(authStateProvider.notifier).logout();
  }
}

// ── Profile card with avatar picker ──────────────────────────────────────────
class _ProfileCard extends ConsumerWidget {
  final String name;
  final String role;
  final String username;
  final String? avatarPath;
  const _ProfileCard({
    required this.name,
    required this.role,
    required this.username,
    required this.avatarPath,
  });

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Change Profile Photo',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B))),
            ),
            ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF8B5CF6), size: 18),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (!kIsWeb)
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF8B5CF6), size: 18),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            if (avatarPath != null)
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.delete_outline,
                      color: Color(0xFFEF4444), size: 18),
                ),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () => Navigator.pop(context, null),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!context.mounted) return;

    // Remove avatar
    if (source == null && avatarPath != null) {
      if (!kIsWeb) {
        try {
          await FileImage(File(avatarPath!)).evict();
          await File(avatarPath!).delete();
        } catch (_) {}
      }
      final ok = await ref.read(authStateProvider.notifier).updateAvatar(null);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Profile photo removed' : 'Failed to remove photo'),
        ));
      }
      return;
    }

    if (source == null) return; // dismissed without selection

    try {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return;
      if (!context.mounted) return;

      String savedPath;

      if (kIsWeb) {
        // On web: read bytes and store as base64 data URI
        final bytes = await image.readAsBytes();
        savedPath = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else {
        // On desktop/mobile: copy to permanent app documents directory
        final appDir = await getApplicationDocumentsDirectory();
        final userId = ref.read(authStateProvider).currentUser?.id ?? 'user';
        final destPath = '${appDir.path}/avatar_$userId.jpg';
        await File(image.path).copy(destPath);
        await FileImage(File(destPath)).evict();
        savedPath = destPath;
      }

      if (!context.mounted) return;
      final ok = await ref
          .read(authStateProvider.notifier)
          .updateAvatar(savedPath);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Profile photo updated' : 'Failed to update photo'),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera/gallery: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: const Color(0xFF4A1580).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(children: [
        // Avatar with edit button
        Stack(
          children: [
            // Avatar circle
            GestureDetector(
              onTap: () => _pickAvatar(context, ref),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: ClipOval(
                  child: avatarPath != null
                      ? PlatformAvatarImage(
                          path: avatarPath!,
                          size: 64,
                          fallbackInitial: name.isNotEmpty
                              ? name[0].toUpperCase() : '?',
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                ),
              ),
            ),
            // Edit badge
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _pickAvatar(context, ref),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.edit,
                      size: 12, color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('@$username',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(role,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
        ),
        // Tap to change hint
        GestureDetector(
          onTap: () => _pickAvatar(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.camera_alt_outlined,
                  size: 12, color: Colors.white70),
              SizedBox(width: 4),
              Text('Edit photo',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ]),
    );
  }
}



// ── Settings section ──────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String label;
  final List<_SettingsItem?> items;
  const _SettingsSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    final validItems = items.whereType<_SettingsItem>().toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B5CF6),
                letterSpacing: 1.2),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: validItems.asMap().entries.map((e) {
              final isLast = e.key == validItems.length - 1;
              return Column(children: [
                e.value,
                if (!isLast) const Divider(height: 1, indent: 50),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6), size: 16),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}

// ── Change password dialog ────────────────────────────────────────────────────
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ChangePasswordDialog({required this.ref});

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = ref.read(authStateProvider).currentUser;
      if (user == null) throw Exception('Not logged in');
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('users', where: 'id = ?', whereArgs: [user.id]);
      if (rows.isEmpty) throw Exception('User not found');
      if (!BCrypt.checkpw(_currentCtrl.text, rows.first['password'] as String)) {
        setState(() { _error = 'Current password is incorrect'; _isLoading = false; });
        return;
      }
      await db.update('users',
          {'password': BCrypt.hashpw(_newCtrl.text, BCrypt.gensalt()), 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?', whereArgs: [user.id]);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
              child: Text(_error!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
            ),
          TextFormField(controller: _currentCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
          const SizedBox(height: 10),
          TextFormField(controller: _newCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) return 'Minimum 8 characters';
                if (v == _currentCtrl.text) return 'Must differ from current';
                return null;
              }),
          const SizedBox(height: 10),
          TextFormField(controller: _confirmCtrl, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              validator: (v) => v != _newCtrl.text ? 'Passwords do not match' : null),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Change'),
        ),
      ],
    );
  }
}