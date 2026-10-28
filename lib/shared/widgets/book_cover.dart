import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class BookCover extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final double? width;
  final double? height;
  final double aspectRatio;
  final double borderRadius;
  final List<BoxShadow>? shadows;
  final bool showSpine;

  const BookCover({
    super.key,
    required this.imageUrl,
    this.title = '',
    this.author = '',
    this.width,
    this.height,
    this.aspectRatio = BookstoreTokens.bookCoverAspectRatio,
    this.borderRadius = BookstoreTokens.bookCoverRadius,
    this.shadows,
    this.showSpine = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadows =
        shadows ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildCoverContent(),
              if (showSpine) _buildSpineOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverContent() {
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildGenericCover(),
      );
    }

    return _buildGenericCover();
  }

  Widget _buildSpineOverlay() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.40),
              Colors.black.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.18),
              Colors.transparent,
            ],
            stops: const [0.0, 0.35, 0.65, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF5EFE6),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(BookstoreTokens.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildGenericCover() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A2826), Color(0xFF191816)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: BookstoreTokens.primary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cormorant Garamond',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
