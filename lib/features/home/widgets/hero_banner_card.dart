import 'package:flutter/material.dart';

import '../../../core/theme/bookstore_tokens.dart';

class HeroBannerCard extends StatelessWidget {
  final VoidCallback onShopNow;

  const HeroBannerCard({super.key, required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF231F1C), Color(0xFF161412), Color(0xFF0F0E0C)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Subtle warm ambient light & plant bokeh
                Positioned(
                  right: -10,
                  top: -20,
                  width: 200,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFBA7822).withValues(alpha: 0.28),
                          const Color(0xFF384E33).withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Stacked Books Illustration / Graphic on right
                Positioned(
                  right: 14,
                  bottom: 16,
                  top: 14,
                  width: 145,
                  child: _StackedBooksVisual(),
                ),
                // Left text content
                Positioned(
                  left: 20,
                  top: 20,
                  bottom: 20,
                  right: 155,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 19.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.15,
                              ),
                              children: [
                                TextSpan(text: 'Discover\nYour Next\n'),
                                TextSpan(
                                  text: 'Favorite Book',
                                  style: TextStyle(
                                    color: Color(0xFFDCA84B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explore bestsellers, new arrivals and timeless classics.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BookstoreTokens.body(
                              fontSize: 10.5,
                              color: Colors.white.withValues(alpha: 0.72),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                      // "Shop Now ->" Pill button
                      GestureDetector(
                        onTap: onShopNow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7.5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              BookstoreTokens.radiusPill,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Shop Now',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1A17),
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Color(0xFF1E1A17),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Pagination dots (1st elongated gold, 3 small grey dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFBA7822),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 5),
            _circleDot(),
            const SizedBox(width: 5),
            _circleDot(),
            const SizedBox(width: 5),
            _circleDot(),
          ],
        ),
      ],
    );
  }

  Widget _circleDot() {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFD4CEC3),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StackedBooksVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Wooden tabletop surface base shadow
        Positioned(
          bottom: 6,
          right: 0,
          left: 10,
          height: 10,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        // Book 3 (bottom) - Dune
        Positioned(
          bottom: 14,
          right: 4,
          child: _BookSpine(
            title: '✦   DUNE   ✦',
            width: 122,
            height: 25,
            color: const Color(0xFF181614),
            textColor: const Color(0xFFE2B258),
            isSerif: true,
          ),
        ),
        // Book 2 (middle) - The 4-Hour Body
        Positioned(
          bottom: 38,
          right: 12,
          child: _BookSpine(
            title: '✦  THE 4-HOUR BODY  ✦',
            width: 114,
            height: 24,
            color: const Color(0xFF866341),
            textColor: Colors.white,
          ),
        ),
        // Book 1 (top) - Atomic Habits
        Positioned(
          bottom: 61,
          right: 20,
          child: _BookSpine(
            title: '✦  Atomic Habits  ✦',
            width: 106,
            height: 23,
            color: const Color(0xFFEDE7DC),
            textColor: const Color(0xFF2E271F),
            isCream: true,
          ),
        ),
      ],
    );
  }
}

class _BookSpine extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final bool isSerif;
  final bool isCream;

  const _BookSpine({
    required this.title,
    required this.width,
    required this.height,
    required this.color,
    required this.textColor,
    this.isSerif = false,
    this.isCream = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: isCream
            ? Border.all(color: const Color(0xFFDFD7CA), width: 0.5)
            : null,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              fontFamily: isSerif ? 'serif' : null,
              letterSpacing: 0.4,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
