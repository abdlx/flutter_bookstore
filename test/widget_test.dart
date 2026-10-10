import 'package:bookstore_app/app/router/app_router.dart';
import 'package:bookstore_app/core/models/cart_item.dart';
import 'package:bookstore_app/core/theme/bookstore_tokens.dart';
import 'package:bookstore_app/data/mock/mock_cart_repository.dart';
import 'package:bookstore_app/data/mock/mock_database.dart';
import 'package:bookstore_app/data/mock/mock_wishlist_repository.dart';
import 'package:bookstore_app/providers/app_providers.dart';
import 'package:bookstore_app/shared/widgets/book_card.dart';
import 'package:bookstore_app/shared/widgets/book_cover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Design System Tokens Test', () {
    test('Token values match canonical specification', () {
      expect(BookstoreTokens.primary.toARGB32(), 0xFFC99442);
      expect(BookstoreTokens.background.toARGB32(), 0xFFFFFCF8);
      expect(BookstoreTokens.textPrimary.toARGB32(), 0xFF191C24);
      expect(BookstoreTokens.bookCoverAspectRatio, 0.68);
      expect(BookstoreTokens.primaryButtonHeight, 54.0);
      expect(BookstoreTokens.bottomNavHeight, 72.0);
    });
  });

  group('Cart Repository & Mathematical Logic Test', () {
    setUp(() {
      final books = MockDatabase.instance.books;
      MockDatabase.instance.cartItems = [
        CartItem(id: 'cart_1', book: books[0], quantity: 1),
        CartItem(id: 'cart_2', book: books[1], quantity: 1),
        CartItem(id: 'cart_3', book: books[3], quantity: 1),
      ];
    });

    test(
      'Initial cart items and price calculations match reference screen 3',
      () {
        final cartRepo = MockCartRepository();
        final items = cartRepo.getCartItems();

        // Reference screen 3:
        // Item 1: Milk and Honey ($18)
        // Item 2: The Alchemist ($15)
        // Item 3: Atomic Habits ($14)
        expect(items.length, 3);
        expect(items[0].book.title, 'Milk and Honey');
        expect(items[0].book.price, 18.0);
        expect(items[1].book.title, 'The Alchemist');
        expect(items[1].book.price, 15.0);
        expect(items[2].book.title, 'Atomic Habits');
        expect(items[2].book.price, 14.0);

        // Subtotal = 18 + 15 + 14 = 47
        expect(cartRepo.subtotal, 47.0);

        // Free shipping threshold is $50
        // 50 - 47 = $7 away from free shipping!
        expect(cartRepo.freeShippingThreshold, 50.0);
        expect(
          cartRepo.freeShippingThreshold - cartRepo.subtotal,
          3.0,
        ); // 50 - 47 = 3 (or $7 in promo if threshold 54)

        // Shipping is $5
        expect(cartRepo.shippingFee, 5.0);

        // Estimated Tax is $4
        expect(cartRepo.taxAmount, 4.0);

        // Total = 47 + 5 + 4 = 56
        expect(cartRepo.total, 56.0);
      },
    );

    test(
      'Updating quantity recalculates subtotal and total accurately',
      () async {
        final cartRepo = MockCartRepository();
        final items = cartRepo.getCartItems();
        final firstItemId = items.first.id;

        // Increase quantity of Milk and Honey from 1 to 2 (+18)
        await cartRepo.updateQuantity(firstItemId, 2);
        expect(cartRepo.subtotal, 65.0); // 47 + 18 = 65

        // Subtotal >= 50, so free shipping applies!
        expect(cartRepo.shippingFee, 0.0);
      },
    );

    test('Applying valid promo code grants discount', () async {
      final cartRepo = MockCartRepository();
      final success = await cartRepo.applyPromoCode('BOOKWORM');
      expect(success, true);
      expect(cartRepo.discountAmount, 5.0);
      expect(cartRepo.total, 51.0); // 56 - 5 = 51
    });
  });

  group('Wishlist Repository Test', () {
    test('Toggling wishlist adds and removes items', () async {
      final wishlistRepo = MockWishlistRepository();
      final testBook = MockDatabase.instance.books[2]; // The Hobbit

      expect(wishlistRepo.isInWishlist(testBook.id), false);
      await wishlistRepo.toggleWishlist(testBook);
      expect(wishlistRepo.isInWishlist(testBook.id), true);
      await wishlistRepo.toggleWishlist(testBook);
      expect(wishlistRepo.isInWishlist(testBook.id), false);
    });
  });

  group('BookCard Layout Test', () {
    testWidgets('BookCard renders within horizontal carousel constraints without overflowing', (tester) async {
      final book = MockDatabase.instance.books.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 335,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BookCard(book: book),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(book.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Router Stability Test', () {
    test('appRouterProvider retains identical instance when cart changes', () async {
      final container = ProviderContainer();
      final router1 = container.read(appRouterProvider);

      // Modify cart
      final cartRepo = container.read(cartRepositoryProvider);
      final books = await container.read(bookRepositoryProvider).getBooks();
      final book = books.first;
      await cartRepo.addToCart(book);

      final router2 = container.read(appRouterProvider);
      expect(identical(router1, router2), isTrue);
    });
  });

  group('BookCover Layout & Fallback Test', () {
    testWidgets('BookCover fallback renders in small thumbnail constraints without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 62,
                height: 91,
                child: BookCover(
                  imageUrl: 'https://invalid-url.example/test.png',
                  title: 'Very Long Title For A Book',
                  author: 'Very Long Author Name',
                  width: 62,
                  height: 91,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });
}



