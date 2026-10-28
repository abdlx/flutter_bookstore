import 'package:bookstore_app/core/models/book.dart';
import 'package:bookstore_app/shared/widgets/book_list_tile.dart';
import 'package:bookstore_app/shared/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookstore_app/shared/widgets/shipping_progress_card.dart';
import 'package:bookstore_app/shared/widgets/profile_avatar.dart';
import 'package:bookstore_app/shared/widgets/book_cover.dart';

void main() {
  testWidgets(
    'shipping progress uses actual threshold with no special-case subtotal',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShippingProgressCard(currentSubtotal: 47, threshold: 50),
          ),
        ),
      );
      expect(find.textContaining('3.00', findRichText: true), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.94);
    },
  );
  testWidgets('zero shipping threshold does not divide by zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShippingProgressCard(currentSubtotal: 10, threshold: 0),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('missing avatar renders neutral person icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileAvatar()));
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
  testWidgets('missing cover displays the supplied Firestore title', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: BookCover(
            imageUrl: '',
            title: 'Actual title',
            width: 100,
            height: 147,
          ),
        ),
      ),
    );
    expect(find.text('Actual title'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'long Firestore metadata fits a narrow list with wishlist actions',
    (tester) async {
      final book = BookItem(
        id: 'book',
        title: 'A long book title from the remote catalog',
        author: 'An author with a long name',
        genre: 'Literary fiction and essays',
        description: '',
        coverUrl: '',
        price: 19.99,
        reviewCount: 1200,
        rating: 4.5,
        publishedDate: DateTime(2026),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: BookListTile(
                  book: book,
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.shopping_cart), Icon(Icons.favorite)],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('large order amounts fit narrow purchase buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 220,
            child: PremiumButton(
              label: 'Place Order - 123456.99',
              onPressed: () {},
              leadingIcon: const Icon(Icons.check),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
