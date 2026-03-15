// lib/presentation/shared/page_layout.dart
// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Wraps any screen content with a max-width constraint and centering.
/// Use this inside every tab's body for consistent desktop/web layout.
class PageLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const PageLayout({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 720;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 16,
                vertical: 20,
              ),
          child: child,
        ),
      ),
    );
  }
}

/// A compact, beautiful record card used across all list screens.
class RecordCard extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? badge;
  final VoidCallback? onTap;
  final Color? accentColor;

  const RecordCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      title,
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        subtitle!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar with initials or icon
class RecordAvatar extends StatelessWidget {
  final String? initials;
  final IconData? icon;
  final Color color;
  final Color bg;
  final double size;

  const RecordAvatar({
    super.key,
    this.initials,
    this.icon,
    required this.color,
    required this.bg,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: initials != null
          ? Center(
              child: Text(
                initials!,
                style: TextStyle(
                  color: color,
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Icon(icon, color: color, size: size * 0.48),
    );
  }
}

/// Small status chip
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Summary stat bar used in ANC / Delivery / Postnatal
class SummaryBar extends StatelessWidget {
  final List<({String label, String value, Color color})> items;

  const SummaryBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        e.value.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: e.value.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        e.value.label,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFF1F5F9),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF8B5CF6);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: c.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B))),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFCBD5E1)),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline,
                  size: 32, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Platform-aware avatar image ───────────────────────────────────────────────
/// Renders a profile avatar from either:
///   - a base64 data URI  → Image.memory  (works everywhere)
///   - a local file path  → Image.file    (desktop/mobile only)
///
/// Used in both app_scaffold.dart (top bar) and settings_screen.dart (profile card).
class PlatformAvatarImage extends StatelessWidget {
  final String path;
  final double size;
  final String fallbackInitial;
  final Color fallbackColor;

  const PlatformAvatarImage({
    super.key,
    required this.path,
    required this.size,
    this.fallbackInitial = '?',
    this.fallbackColor = const Color(0xFF8B5CF6),
  });

  bool get _isBase64 => path.startsWith('data:');

  Widget _fallback() => Container(
        width: size,
        height: size,
        color: fallbackColor,
        child: Center(
          child: Text(
            fallbackInitial,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isBase64) {
      try {
        final bytes = base64Decode(path.split(',').last);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      } catch (_) {
        return _fallback();
      }
    }

    // File path — not available on web
    if (kIsWeb) return _fallback();

    return Image.file(
      File(path),
      width: size,
      height: size,
      fit: BoxFit.cover,
      key: ValueKey(path), // prevents stale widget reuse
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}