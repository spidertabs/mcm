// test/widget_test.dart
//
// Widget & unit tests for MaternalCare Monitor.
// Run with:  flutter test
//
// Coverage:
//   1.  AppValidators — username, password, required, phone, email,
//                       confirmPassword, combine
//   2.  RecordAvatar  — initials, icon, size
//   3.  StatusChip    — label rendering
//   4.  EmptyState    — title, subtitle, icon
//   5.  ErrorState    — message, retry callback
//   6.  SummaryBar    — labels and values
//   7.  RecordCard    — title, subtitle, trailing, onTap
//   8.  PageLayout    — child rendering, maxWidth constraint
//   9.  Form validation — login fields (isolated, no routing)
//  10.  AppValidators edge cases

// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maternal_care_monitor/core/utils/validators.dart';
import 'package:maternal_care_monitor/presentation/shared/page_layout.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — wraps any widget in the minimum harness needed for rendering
// ─────────────────────────────────────────────────────────────────────────────
Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. AppValidators.username
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.username', () {
    final v = AppValidators.username;

    test('null → error', () => expect(v(null), isNotNull));
    test('empty → error', () => expect(v(''), isNotNull));
    test('whitespace only → error', () => expect(v('   '), isNotNull));
    test('length 2 → error', () => expect(v('ab'), isNotNull));
    test('exactly 3 chars → null', () => expect(v('abc'), isNull));
    test('valid username → null', () => expect(v('sarahmabike'), isNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 2. AppValidators.password
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.password', () {
    final v = AppValidators.password;

    test('null → error', () => expect(v(null), isNotNull));
    test('empty → error', () => expect(v(''), isNotNull));
    test('5 chars → error', () => expect(v('12345'), isNotNull));
    test('exactly 6 chars → null', () => expect(v('abcdef'), isNull));
    test('valid password → null', () => expect(v('demo1234'), isNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 3. AppValidators.required
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.required', () {
    test('null → error', () => expect(AppValidators.required(null), isNotNull));
    test('empty → error', () => expect(AppValidators.required(''), isNotNull));
    test('whitespace → error',
        () => expect(AppValidators.required('   '), isNotNull));
    test('fieldName in message', () {
      final err = AppValidators.required('', 'Full name');
      expect(err, contains('Full name'));
    });
    test('non-empty → null',
        () => expect(AppValidators.required('Apio Grace'), isNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 4. AppValidators.phone
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.phone', () {
    test('null → null (optional)', () => expect(AppValidators.phone(null), isNull));
    test('empty → null (optional)', () => expect(AppValidators.phone(''), isNull));
    test('letters → error', () => expect(AppValidators.phone('abcdefghi'), isNotNull));
    test('8 digits → error (too short)',
        () => expect(AppValidators.phone('12345678'), isNotNull));
    test('9 digits → null', () => expect(AppValidators.phone('772123456'), isNull));
    test('+256 prefix → null',
        () => expect(AppValidators.phone('+256772123456'), isNull));
    test('spaces → error',
        () => expect(AppValidators.phone('0772 123 456'), isNotNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 5. AppValidators.email
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.email', () {
    test('null → null (optional)', () => expect(AppValidators.email(null), isNull));
    test('empty → null (optional)', () => expect(AppValidators.email(''), isNull));
    test('no @ → error', () => expect(AppValidators.email('notanemail'), isNotNull));
    test('missing domain → error',
        () => expect(AppValidators.email('user@'), isNotNull));
    test('valid email → null',
        () => expect(AppValidators.email('sarah@health.go.ug'), isNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 6. AppValidators.confirmPassword
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.confirmPassword', () {
    test('null value → error',
        () => expect(AppValidators.confirmPassword(null, 'demo1234'), isNotNull));
    test('empty value → error',
        () => expect(AppValidators.confirmPassword('', 'demo1234'), isNotNull));
    test('mismatch → error',
        () => expect(AppValidators.confirmPassword('abc', 'xyz'), isNotNull));
    test('match → null',
        () => expect(AppValidators.confirmPassword('demo1234', 'demo1234'), isNull));
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 7. AppValidators.combine
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators.combine', () {
    test('returns first failing error', () {
      final result =
          AppValidators.combine('', [AppValidators.required, AppValidators.phone]);
      expect(result, isNotNull);
    });

    test('returns null when all pass', () {
      final result = AppValidators.combine('Apio Grace', [AppValidators.required]);
      expect(result, isNull);
    });

    test('stops at first error — second validator not reached', () {
      int calls = 0;
      String? counter(String? v) { calls++; return null; }
      AppValidators.combine('', [AppValidators.required, counter]);
      expect(calls, equals(0));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 8. AppValidators edge cases
  // ───────────────────────────────────────────────────────────────────────────
  group('AppValidators edge cases', () {
    test('username: leading/trailing spaces fail length check', () {
      // '  a  ' trimmed = 'a' — length 1
      expect(AppValidators.username('  a  '), isNotNull);
    });

    test('required: tab characters count as whitespace', () {
      expect(AppValidators.required('\t\t'), isNotNull);
    });

    test('password: exactly 6 alphanumeric passes', () {
      expect(AppValidators.password('abc123'), isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 9. RecordAvatar widget
  // ───────────────────────────────────────────────────────────────────────────
  group('RecordAvatar', () {
    testWidgets('renders initials text', (tester) async {
      await tester.pumpWidget(_wrap(const RecordAvatar(
        initials: 'AG',
        color: Color(0xFF8B5CF6),
        bg: Color(0xFFEDE9FE),
      )));
      expect(find.text('AG'), findsOneWidget);
    });

    testWidgets('renders icon when no initials', (tester) async {
      await tester.pumpWidget(_wrap(const RecordAvatar(
        icon: Icons.person,
        color: Color(0xFF8B5CF6),
        bg: Color(0xFFEDE9FE),
      )));
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('default size is 40', (tester) async {
      await tester.pumpWidget(_wrap(const RecordAvatar(
        initials: 'XX',
        color: Colors.purple,
        bg: Colors.purple,
      )));
      final box = tester.getSize(find.byType(RecordAvatar));
      expect(box.width, equals(40));
      expect(box.height, equals(40));
    });

    testWidgets('respects custom size', (tester) async {
      await tester.pumpWidget(_wrap(const RecordAvatar(
        initials: 'XX',
        color: Colors.teal,
        bg: Colors.teal,
        size: 56,
      )));
      final box = tester.getSize(find.byType(RecordAvatar));
      expect(box.width, equals(56));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 10. StatusChip widget
  // ───────────────────────────────────────────────────────────────────────────
  group('StatusChip', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(_wrap(const StatusChip(
        label: 'High Risk',
        color: Color(0xFFEF4444),
        bg: Color(0xFFFEF2F2),
      )));
      expect(find.text('High Risk'), findsOneWidget);
    });

    testWidgets('renders different label', (tester) async {
      await tester.pumpWidget(_wrap(const StatusChip(
        label: 'Live Birth',
        color: Color(0xFF10B981),
        bg: Color(0xFFD1FAE5),
      )));
      expect(find.text('Live Birth'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 11. EmptyState widget
  // ───────────────────────────────────────────────────────────────────────────
  group('EmptyState', () {
    testWidgets('shows title and icon', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.people_outline,
        title: 'No patients yet',
      )));
      expect(find.text('No patients yet'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.people_outline,
        title: 'No patients yet',
        subtitle: 'Tap + to register the first patient',
      )));
      expect(find.text('Tap + to register the first patient'), findsOneWidget);
    });

    testWidgets('subtitle absent when not provided', (tester) async {
      await tester.pumpWidget(_wrap(const EmptyState(
        icon: Icons.people_outline,
        title: 'No records',
      )));
      expect(find.text('Tap + to register the first patient'), findsNothing);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 12. ErrorState widget
  // ───────────────────────────────────────────────────────────────────────────
  group('ErrorState', () {
    testWidgets('shows message', (tester) async {
      await tester.pumpWidget(_wrap(
          ErrorState(message: 'Database failed', onRetry: () {})));
      expect(find.text('Database failed'), findsOneWidget);
    });

    testWidgets('shows Retry button', (tester) async {
      await tester.pumpWidget(_wrap(
          ErrorState(message: 'Error', onRetry: () {})));
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Retry triggers callback', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(
          ErrorState(message: 'Error', onRetry: () => called = true)));
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(called, isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 13. SummaryBar widget
  // ───────────────────────────────────────────────────────────────────────────
  group('SummaryBar', () {
    testWidgets('renders all labels and values', (tester) async {
      await tester.pumpWidget(_wrap(SummaryBar(items: [
        (label: 'This Month', value: '9', color: const Color(0xFF8B5CF6)),
        (label: 'ANC 1st Visit', value: '100', color: const Color(0xFF0EA5E9)),
        (label: 'ANC 4+ Visits', value: '0', color: const Color(0xFF10B981)),
      ])));
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('ANC 1st Visit'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('handles 4 items without overflow', (tester) async {
      await tester.pumpWidget(_wrap(SummaryBar(items: [
        (label: 'A', value: '1', color: Colors.blue),
        (label: 'B', value: '2', color: Colors.green),
        (label: 'C', value: '3', color: Colors.red),
        (label: 'D', value: '4', color: Colors.orange),
      ])));
      expect(find.text('D'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 14. RecordCard widget
  // ───────────────────────────────────────────────────────────────────────────
  group('RecordCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(_wrap(RecordCard(
        leading: const RecordAvatar(
            initials: 'AG', color: Colors.purple, bg: Colors.purple),
        title: const Text('Apio Grace'),
      )));
      expect(find.text('Apio Grace'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(RecordCard(
        leading: const RecordAvatar(
            initials: 'AG', color: Colors.purple, bg: Colors.purple),
        title: const Text('Apio Grace'),
        subtitle: const Text('28 yrs · Rubare'),
      )));
      expect(find.text('28 yrs · Rubare'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(RecordCard(
        onTap: () => tapped = true,
        leading: const RecordAvatar(
            initials: 'AG', color: Colors.purple, bg: Colors.purple),
        title: const Text('Tap Me'),
      )));
      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(_wrap(RecordCard(
        leading: const RecordAvatar(
            initials: 'AG', color: Colors.purple, bg: Colors.purple),
        title: const Text('Card'),
        trailing: const StatusChip(
            label: 'High BP',
            color: Color(0xFFEF4444),
            bg: Color(0xFFFEF2F2)),
      )));
      expect(find.text('High BP'), findsOneWidget);
    });

    testWidgets('works without optional params', (tester) async {
      await tester.pumpWidget(_wrap(RecordCard(
        leading: const RecordAvatar(
            initials: 'XX', color: Colors.teal, bg: Colors.teal),
        title: const Text('Minimal'),
      )));
      expect(tester.takeException(), isNull);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 15. PageLayout widget
  // ───────────────────────────────────────────────────────────────────────────
  group('PageLayout', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
          const PageLayout(child: Text('Hello PageLayout'))));
      expect(find.text('Hello PageLayout'), findsOneWidget);
    });

    testWidgets('default maxWidth 960 is applied as a ConstrainedBox',
        (tester) async {
      await tester.pumpWidget(_wrap(
          const PageLayout(child: Text('Content'))));
      final boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((b) => b.constraints.maxWidth == 960);
      expect(boxes, isNotEmpty);
    });

    testWidgets('custom maxWidth is respected', (tester) async {
      await tester.pumpWidget(_wrap(
          const PageLayout(maxWidth: 500, child: Text('Narrow'))));
      final boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((b) => b.constraints.maxWidth == 500);
      expect(boxes, isNotEmpty);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // 16. Form validation — login fields (isolated, no routing needed)
  // ───────────────────────────────────────────────────────────────────────────
  group('Login form validation', () {
    Widget _loginForm() {
      final formKey = GlobalKey<FormState>();
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(children: [
                TextFormField(
                    key: const Key('user'),
                    validator: AppValidators.username),
                TextFormField(
                    key: const Key('pass'),
                    validator: AppValidators.password),
                ElevatedButton(
                    onPressed: () => formKey.currentState!.validate(),
                    child: const Text('Login')),
              ]),
            ),
          ),
        ),
      );
    }

    testWidgets('empty submit shows both errors', (tester) async {
      await tester.pumpWidget(_loginForm());
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('valid input clears errors', (tester) async {
      await tester.pumpWidget(_loginForm());
      // trigger errors first
      await tester.tap(find.text('Login'));
      await tester.pump();
      // fill in valid values
      await tester.enterText(find.byKey(const Key('user')), 'sarahmabike');
      await tester.enterText(find.byKey(const Key('pass')), 'demo1234');
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Username is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('short username shows length error', (tester) async {
      await tester.pumpWidget(_loginForm());
      await tester.enterText(find.byKey(const Key('user')), 'ab');
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(
          find.text('Username must be at least 3 characters'), findsOneWidget);
    });

    testWidgets('short password shows length error', (tester) async {
      await tester.pumpWidget(_loginForm());
      await tester.enterText(find.byKey(const Key('pass')), '123');
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}