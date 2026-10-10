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
    final booksAsync = ref.watch(allBooksStreamProvider);
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
      data: (books) {
        final book = books.firstWhere(
          (b) => b.id == widget.bookId,
          orElse: () => books.first,
        );

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
                    _buildTopCanvas(context, book, isInWishlist, () {
                      wishlistRepo.toggleWishlist(book);
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
                                        fontFamily: 'serif',
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
                                      color: Color(0xFFBA7822),
                                    ),
                                  ),
                                  if (book.originalPrice != null)
                                    Text(
                                      '\$${book.originalPrice!.toStringAsFixed(0)}',
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
                                        color: Color(0xFFBA7822),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'Bestseller',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFBA7822),
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
                                          color: const Color(0xFFF7F2E8),
                                          borderRadius: BorderRadius.circular(
                                            BookstoreTokens.radiusPill,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFBA7822),
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
                        icon: Icons.ios_share_rounded,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sharing book link...'),
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

            // Pagination dots (exactly 3 dots in reference image)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 14,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA7822),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 5),
                _smallDot(),
                const SizedBox(width: 5),
                _smallDot(),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _smallDot() {
    return Container(
      width: 4.5,
      height: 4.5,
      decoration: const BoxDecoration(
        color: Color(0xFFD4CEC3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMetadataPanel(BookItem book) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
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
                fontFamily: 'serif',
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Color(0xFF191C24),
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: List.generate(5, (index) {
                return const Icon(
                  Icons.star_rounded,
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
              _RatingBarRow(stars: 5, pct: book.ratingBreakdown[5] ?? 0.82),
              _RatingBarRow(stars: 4, pct: book.ratingBreakdown[4] ?? 0.12),
              _RatingBarRow(stars: 3, pct: book.ratingBreakdown[3] ?? 0.04),
              _RatingBarRow(stars: 2, pct: book.ratingBreakdown[2] ?? 0.01),
              _RatingBarRow(stars: 1, pct: book.ratingBreakdown[1] ?? 0.01),
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
            backgroundColor: const Color(0xFFF7F2E8),
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
              label: 'Add to Cart',
              leadingIcon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 20,
              ),
              height: 52,
              borderRadius: 26,
              onPressed: () {
                cartRepo.addToCart(book, quantity: _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $_quantity "${book.title}" to cart'),
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
                    Color(0xFFBA7822),
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
