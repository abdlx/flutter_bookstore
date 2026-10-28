import 'package:flutter/services.dart';

import '../../../core/utils/store_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/book.dart';
import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_cover.dart';
import '../../../shared/widgets/premium_button.dart';
import '../../../shared/widgets/quantity_stepper.dart';

class BookDetailsScreen extends ConsumerStatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  ConsumerState<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends ConsumerState<BookDetailsScreen> {
  int _quantity = 1;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bookDetailsProvider(widget.bookId));
    final wishlistAsync = ref.watch(wishlistStreamProvider);
    final wishlistRepo = ref.read(wishlistRepositoryProvider);
    final cartRepo = ref.read(cartRepositoryProvider);

    return booksAsync.when(
      loading: () => const Scaffold(
        backgroundColor: BookstoreTokens.background,
        body: Center(
          child: CircularProgressIndicator(color: BookstoreTokens.primary),
        ),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (book) {
        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book unavailable')),
            body: const Center(
              child: Text('This book is no longer available.'),
            ),
          );
        }

        final isInWishlist =
            wishlistAsync.value?.any((b) => b.id == book.id) ?? false;

        return Scaffold(
          backgroundColor: BookstoreTokens.background,
          body: Stack(
            children: [
              // Scrollable content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Canvas with warm beige gradient and floating cover
                    _buildTopCanvas(context, book, isInWishlist, () async {
                      await storeAction(
                        context,
                        ref,
                        () => wishlistRepo.toggleWishlist(book),
                      );
                    }),

                    // Book Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Title, Author and Price Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontFamily: 'Cormorant Garamond',
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF191C24),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: BookstoreTokens.body(
                                        fontSize: 14,
                                        color: const Color(0xFF7A7875),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Gold Price + Strikethrough Original Price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${book.price.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: BookstoreTokens.primary,
                                    ),
                                  ),
                                  if (book.originalPrice != null)
                                    Text(
                                      '\$${book.originalPrice!.toStringAsFixed(2)}',
                                      style: BookstoreTokens.body(
                                        fontSize: 14,
                                        color: const Color(0xFF9E9E9E),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Rating and Bestseller Badge Row
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Color(0xFFF5A623),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                book.rating.toStringAsFixed(1),
                                style: BookstoreTokens.body(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF191C24),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${book.reviewCount} reviews)',
                                style: BookstoreTokens.body(
                                  fontSize: 13,
                                  color: const Color(0xFF7A7875),
                                ),
                              ),
                              if (book.isBestseller) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF4E7),
                                    borderRadius: BorderRadius.circular(
                                      BookstoreTokens.radiusPill,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 13,
                                        color: BookstoreTokens.primary,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'Bestseller',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: BookstoreTokens.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Category Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (book.tags.isNotEmpty
                                        ? book.tags
                                        : [book.genre])
                                    .map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BookstoreTokens.surfaceWarm,
                                          borderRadius: BorderRadius.circular(
                                            BookstoreTokens.radiusPill,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: BookstoreTokens.primary,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),

                          const SizedBox(height: 20),

                          // 3-Column Metadata Panel
                          _buildMetadataPanel(book),

                          const SizedBox(height: 24),

                          // "About this book" Section
                          Text(
                            'About this book',
                            style: BookstoreTokens.body(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: BookstoreTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book.description,
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded
                                ? null
                                : TextOverflow.ellipsis,
                            style: BookstoreTokens.body(
                              fontSize: 13.5,
                              color: BookstoreTokens.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDescriptionExpanded =
                                    !_isDescriptionExpanded;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isDescriptionExpanded
                                      ? 'Read less'
                                      : 'Read more',
                                  style: BookstoreTokens.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BookstoreTokens.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isDescriptionExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: BookstoreTokens.primary,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // "Customer Reviews" Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Customer Reviews',
                                style: BookstoreTokens.body(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: BookstoreTokens.textPrimary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.push('/book/${book.id}/reviews'),
                                child: Text(
                                  'See all',
                                  style: BookstoreTokens.body(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: BookstoreTokens.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Reviews Breakdown
                          _buildReviewsBreakdown(book),

                          // Bottom padding for persistent action bar
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Persistent Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomActionBar(context, book, cartRepo),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopCanvas(
    BuildContext context,
    BookItem book,
    bool isInWishlist,
    VoidCallback onToggleWishlist,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3ECE0),
            Color(0xFFFAF6EE),
            BookstoreTokens.background,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header buttons: Back, Wishlist, Share
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleActionBtn(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Row(
                    children: [
                      _CircleActionBtn(
                        icon: isInWishlist
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: isInWishlist
                            ? BookstoreTokens.primary
                            : BookstoreTokens.textPrimary,
                        onTap: onToggleWishlist,
                      ),
                      const SizedBox(width: 12),
                      _CircleActionBtn(
                        icon: Icons.link_rounded,
                        onTap: () async {
                          final configured =
                              ref
                                      .read(storeSettingsProvider)
                                      .value?['storefrontUrl']
                                  as String?;
                          final base = Uri.tryParse(
                            configured ?? Uri.base.toString(),
                          );
                          final link =
                              base != null &&
                                  ['http', 'https'].contains(base.scheme)
                              ? base
                                    .replace(
                                      fragment:
                                          '/book/${Uri.encodeComponent(book.id)}',
                                    )
                                    .toString()
                              : null;
                          await Clipboard.setData(
                            ClipboardData(
                              text: link ?? '${book.title} by ${book.author}',
                            ),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                link == null
                                    ? 'Book details copied'
                                    : 'Book link copied',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Floating Book Cover
            Center(
              child: BookCover(
                imageUrl: book.coverUrl,
                title: book.title,
                author: book.author,
                width: 180,
                height: 180 / BookstoreTokens.bookCoverAspectRatio,
                borderRadius: 10,
                shadows: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 32,
                    spreadRadius: -2,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataPanel(BookItem book) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: BookstoreTokens.surfaceWarm,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetadataColumn(
              icon: Icons.menu_book_outlined,
              label: book.format,
              value: '${book.pages} pages',
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE8E0D2)),
          Expanded(
            child: _MetadataColumn(
              icon: Icons.grid_view_rounded,
              label: 'Language',
              value: book.language,
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE8E0D2)),
          Expanded(
            child: _MetadataColumn(
              icon: Icons.public_rounded,
              label: 'Publisher',
              value: book.publisher,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsBreakdown(BookItem book) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Large rating score and stars
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C24),
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < book.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 16,
                  color: Color(0xFFF5A623),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '${book.reviewCount} reviews',
              style: BookstoreTokens.body(
                fontSize: 11.5,
                color: const Color(0xFF7A7875),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Progress Bars for 5, 4, 3, 2, 1 stars
        Expanded(
          child: Column(
            children: [
              _RatingBarRow(stars: 5, pct: book.ratingBreakdown[5] ?? 0),
              _RatingBarRow(stars: 4, pct: book.ratingBreakdown[4] ?? 0),
              _RatingBarRow(stars: 3, pct: book.ratingBreakdown[3] ?? 0),
              _RatingBarRow(stars: 2, pct: book.ratingBreakdown[2] ?? 0),
              _RatingBarRow(stars: 1, pct: book.ratingBreakdown[1] ?? 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    BookItem book,
    dynamic cartRepo,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity stepper
          QuantityStepper(
            quantity: _quantity,
            height: 48,
            backgroundColor: BookstoreTokens.surfaceWarm,
            onChanged: (newQty) {
              setState(() {
                _quantity = newQty;
              });
            },
          ),
          const SizedBox(width: 14),
          // Prominent Gold Add to Cart button
          Expanded(
            child: PremiumButton(
              label: book.stockQuantity <= 0 ? 'Out of stock' : 'Add to Cart',
              leadingIcon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
              height: 52,
              borderRadius: 26,
              onPressed: book.stockQuantity <= 0
                  ? null
                  : () async {
                      if (!await storeAction(
                        context,
                        ref,
                        () => cartRepo.addToCart(book, quantity: _quantity),
                      )) {
                        return;
                      }
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added $_quantity "${book.title}" to cart',
                          ),
                          backgroundColor: BookstoreTokens.textPrimary,
                          action: SnackBarAction(
                            label: 'View Cart',
                            textColor: BookstoreTokens.primaryLight,
                            onPressed: () => context.go('/cart'),
                          ),
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleActionBtn({
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: BookstoreTokens.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: iconColor ?? BookstoreTokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MetadataColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataColumn({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: BookstoreTokens.textPrimary),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BookstoreTokens.body(
            fontSize: 11,
            color: BookstoreTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BookstoreTokens.body(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: BookstoreTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  final int stars;
  final double pct;

  const _RatingBarRow({required this.stars, required this.pct});

  @override
  Widget build(BuildContext context) {
    final pctString = '${(pct * 100).toInt()}%';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(
            '$stars',
            style: BookstoreTokens.body(
              fontSize: 11,
              color: BookstoreTokens.textSecondary,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.star_rounded,
            size: 11,
            color: BookstoreTokens.rating,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 5.5,
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: const Color(0xFFE8E2D8),
                  valueColor: const AlwaysStoppedAnimation(
                    BookstoreTokens.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              pctString,
              textAlign: TextAlign.end,
              style: BookstoreTokens.body(
                fontSize: 11,
                color: BookstoreTokens.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
