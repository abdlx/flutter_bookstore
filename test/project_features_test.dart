import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookstore_app/providers/app_providers.dart';
import 'package:bookstore_app/data/contracts/admin_repository.dart';
import 'package:bookstore_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:bookstore_app/features/admin/screens/promotion_management_screen.dart';
import 'package:bookstore_app/features/policies/policy_screen.dart';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookstore_app/core/models/book.dart';
import 'package:bookstore_app/core/models/promotion.dart';
import 'package:bookstore_app/core/models/review.dart';
import 'package:bookstore_app/data/firestore/catalog_queries.dart';
import 'package:bookstore_app/data/firestore/firestore_media_repository.dart';
import 'package:bookstore_app/shared/widgets/review_card.dart';

void main() {
  final book = BookItem(
    id: 'real-id',
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt',
    genre: 'Technology',
    description: '',
    coverUrl: '',
    price: 19.99,
    publishedDate: DateTime(1999),
  );
  test('catalog indexes word prefixes and searches independent title and author terms', () {
    expect(
      searchTokens(book),
      containsAll(['prag', 'program', 'andrew', 'tech']),
    );
    expect(matchesCatalog(book, 'program hunt', 20), isTrue);
    expect(matchesCatalog(book, 'program hunt', 19), isFalse);
    expect(normalizeSearch('  HELLO, World! '), 'hello world');
    expect(
      normalizeSearch('\u06a9\u062a\u0627\u0628'),
      '\u06a9\u062a\u0627\u0628',
    );
    expect(
      searchTokens(book.copyWith(title: 'x' * 5000)).length,
      lessThanOrEqualTo(1600),
    );
  });
  test('promotion validation rejects invalid amounts and codes', () {
    const Promotion(
      code: 'SCHOOL10',
      active: true,
      type: 'percent',
      amount: 10,
    ).validate();
    for (final promotion in [
      const Promotion(code: 'bad/code', active: true, type: 'fixed', amount: 1),
      const Promotion(
        code: 'VALID',
        active: true,
        type: 'percent',
        amount: 101,
      ),
      const Promotion(code: 'VALID', active: true, type: 'fixed', amount: 0),
      const Promotion(
        code: 'VALID',
        active: true,
        type: 'fixed',
        amount: 1,
        minimumSubtotal: -1,
      ),
    ]) {
      expect(promotion.validate, throwsArgumentError);
    }
  });
  testWidgets('review helpful action works when count is zero', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReviewCard(
            review: const ReviewItem(
              id: 'other',
              bookId: 'title',
              userName: 'Reader',
              userAvatar: '',
              rating: 4,
              dateString: '2026-10-28',
              content: 'Useful review.',
            ),
            onHelpful: () => taps++,
          ),
        ),
      ),
    );
    expect(find.text('Helpful (0)'), findsOneWidget);
    await tester.tap(find.text('Helpful (0)'));
    expect(taps, 1);
  });
  testWidgets(
    'image preparation creates a bounded PNG from selected image bytes',
    (tester) async {
      await tester.runAsync(() async {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawRect(
          const ui.Rect.fromLTWH(0, 0, 1200, 1600),
          ui.Paint()..color = const ui.Color(0xffc99442),
        );
        final picture = recorder.endRecording();
        final image = await picture.toImage(1200, 1600);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = await prepareStoreImage(data!.buffer.asUint8List());
        expect(bytes.length, lessThanOrEqualTo(450000));
        expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        expect(descriptor.width, lessThanOrEqualTo(768));
        expect(descriptor.height, lessThanOrEqualTo(768));
        descriptor.dispose();
        buffer.dispose();
        image.dispose();
        picture.dispose();
        await expectLater(prepareStoreImage(Uint8List(0)), throwsArgumentError);
        await expectLater(
          prepareStoreImage(Uint8List(10 * 1024 * 1024 + 1)),
          throwsArgumentError,
        );
      });
    },
  );
  testWidgets('published policy content updates without reopening the page', (
    tester,
  ) async {
    final updates = StreamController<Map<String, dynamic>?>();
    addTearDown(updates.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          policyProvider('terms').overrideWith((ref) => updates.stream),
        ],
        child: const MaterialApp(home: PolicyScreen(id: 'terms')),
      ),
    );
    updates.add({
      'title': 'Project terms',
      'version': '1',
      'content': 'First published policy.',
    });
    await tester.pump();
    await tester.pump();
    expect(find.text('First published policy.'), findsOneWidget);
    updates.add({
      'title': 'Project terms',
      'version': '2',
      'content': 'Updated published policy.',
    });
    await tester.pump();
    await tester.pump();
    expect(find.text('Updated published policy.'), findsOneWidget);
    expect(find.text('Version 2'), findsOneWidget);
  });
  testWidgets(
    'administrator dashboard reacts to live revenue and order updates',
    (tester) async {
      final updates = StreamController<AdminDashboardStats>();
      addTearDown(updates.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [adminStatsProvider.overrideWithValue(updates.stream)],
          child: const MaterialApp(home: AdminDashboardScreen()),
        ),
      );
      updates.add(
        const AdminDashboardStats(
          totalRevenue: 10,
          totalOrders: 1,
          totalBooks: 4,
          totalUsers: 2,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(r'$10.00'), findsOneWidget);
      updates.add(
        const AdminDashboardStats(
          totalRevenue: 37.55,
          totalOrders: 2,
          totalBooks: 4,
          totalUsers: 2,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(r'$37.55'), findsOneWidget);
    },
  );
  testWidgets(
    'promotion editor validates invalid codes and percentages before writing',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            promotionsProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(home: PromotionManagementScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Create Promotion'),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'bad/code');
      await tester.enterText(fields.at(1), '101');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(find.textContaining('letters, numbers'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );
}
