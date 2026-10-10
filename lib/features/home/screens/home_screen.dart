import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bookstore_tokens.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/widgets/book_card.dart';
import '../../../shared/widgets/category_selector.dart';
import '../../../shared/widgets/premium_search_bar.dart';
import '../../../shared/widgets/section_header.dart';
import '../widgets/hero_banner_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Education',
    'Self Help',
  ];

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(allBooksStreamProvider);
    final userAsync = ref.watch(currentUserStreamProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);

    final user = userAsync.value;
    final userName = user?.fullName.split(' ').first ?? 'Alex';

    return Scaffold(
      backgroundColor: BookstoreTokens.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: BookstoreTokens.primary,
          onRefresh: () async {
            ref.invalidate(allBooksStreamProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Header with greeting, bell, and avatar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: BookstoreTokens.body(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF7A7875),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$userName 👋',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191C24),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Notification Bell with unread dot
                          _HeaderCircleButton(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF191C24),
                                  size: 22,
                                ),
                                Positioned(
                                  top: 1,
                                  right: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE54D42),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No new notifications today'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          // User Avatar
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(
                                    user?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  child: PremiumSearchBar(
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    onFilterTap: () => context.push('/search'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Horizontal Category Chips
              SliverToBoxAdapter(
                child: CategorySelector(
                  categories: _categories,
                  selectedCategory: selectedGenre,
                  onSelected: (genre) {
                    ref.read(selectedGenreProvider.notifier).state = genre;
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Hero Banner
              SliverToBoxAdapter(
                child: HeroBannerCard(
                  onShopNow: () => context.push('/explore'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 26)),

              // "Recommended for you" Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Recommended for you',
                  actionText: 'See all',
                  onActionTap: () => context.push('/explore'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Recommended Carousel
              SliverToBoxAdapter(
                child: booksAsync.when(
                  loading: () => const SizedBox(
                    height: 335,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: BookstoreTokens.primary,
                      ),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (books) {
                    final recommended = books.where((b) {
                      if (selectedGenre != 'All') {
                        return b.genre.toLowerCase() ==
                                selectedGenre.toLowerCase() ||
                            b.tags.any(
                              (t) =>
                                  t.toLowerCase() ==
                                  selectedGenre.toLowerCase(),
                            );
                      }
                      return b.isRecommended;
                    }).toList();

                    final displayBooks = recommended.isNotEmpty
                        ? recommended
                        : books.take(5).toList();

                    return SizedBox(
                      height: 335,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayBooks.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final book = displayBooks[index];
                          return BookCard(
                            book: book,
                            onTap: () => context.push('/book/${book.id}'),
                            onAddToCart: () {
                              ref.read(cartRepositoryProvider).addToCart(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added "${book.title}" to cart',
                                  ),
                                  backgroundColor: BookstoreTokens.textPrimary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // "Best Sellers" Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Best Sellers',
                  actionText: 'See all',
                  onActionTap: () => context.push('/explore'),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Best Sellers Horizontal List
              SliverToBoxAdapter(
                child: booksAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (books) {
                    final bestsellers = books
                        .where((b) => b.isBestseller)
                        .toList();
                    return SizedBox(
                      height: 335,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: bestsellers.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final book = bestsellers[index];
                          return BookCard(
                            book: book,
                            onTap: () => context.push('/book/${book.id}'),
                            onAddToCart: () {
                              ref.read(cartRepositoryProvider).addToCart(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Added "${book.title}" to cart',
                                  ),
                                  backgroundColor: BookstoreTokens.textPrimary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HeaderCircleButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
