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
    this.borderRadius = 12.0,
    this.shadows,
    this.showSpine = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShadows = shadows ?? [
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
    final lowerTitle = title.toLowerCase().trim();
    if (lowerTitle.contains('milk and honey')) {
      return const _MilkAndHoneyCover();
    } else if (lowerTitle.contains('alchemist')) {
      return const _TheAlchemistCover();
    } else if (lowerTitle.contains('hobbit')) {
      return const _TheHobbitCover();
    } else if (lowerTitle.contains('atomic habits')) {
      return const _AtomicHabitsCover();
    } else if (lowerTitle.contains('dune')) {
      return const _DuneCover();
    } else if (lowerTitle.contains('think again')) {
      return const _ThinkAgainCover();
    }

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
            valueColor: AlwaysStoppedAnimation(Color(0xFFBA7822)),
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
              color: Color(0xFFBA7822),
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
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Pixel-Perfect Cover for "milk and honey"
class _MilkAndHoneyCover extends StatelessWidget {
  const _MilkAndHoneyCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1918),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top Title & Author
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'milk and\nhoney',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'rupi kaur',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: Color(0xFFD6D3CD),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Bees line art illustration
          Center(
            child: CustomPaint(
              size: const Size(110, 80),
              painter: _BeesPainter(),
            ),
          ),
          // Bottom Bestseller text
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'NEW YORK TIMES BESTSELLER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 6.5,
                  color: Color(0xFFBA7822),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFECE7DE)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Bee 1 (upper right)
    _drawBee(canvas, paint, Offset(size.width * 0.65, size.height * 0.35), 0.75);

    // Bee 2 (lower left)
    _drawBee(canvas, paint, Offset(size.width * 0.32, size.height * 0.72), 0.70);
  }

  void _drawBee(Canvas canvas, Paint paint, Offset center, double scale) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    // Body
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(center: Offset.zero, width: 9, height: 16));
    canvas.drawPath(bodyPath, paint);

    // Stripes
    canvas.drawLine(const Offset(-4, -2), const Offset(4, -2), paint);
    canvas.drawLine(const Offset(-4.5, 2), const Offset(4.5, 2), paint);

    // Left Wing
    final leftWing = Path();
    leftWing.moveTo(-2, -3);
    leftWing.quadraticBezierTo(-16, -14, -14, -2);
    leftWing.quadraticBezierTo(-10, 4, -2, 0);
    canvas.drawPath(leftWing, paint);

    // Right Wing
    final rightWing = Path();
    rightWing.moveTo(2, -3);
    rightWing.quadraticBezierTo(16, -14, 14, -2);
    rightWing.quadraticBezierTo(10, 4, 2, 0);
    canvas.drawPath(rightWing, paint);

    // Antennae
    final leftAntenna = Path()..moveTo(-1.5, -8)..quadraticBezierTo(-4, -12, -6, -11);
    final rightAntenna = Path()..moveTo(1.5, -8)..quadraticBezierTo(4, -12, 6, -11);
    canvas.drawPath(leftAntenna, paint);
    canvas.drawPath(rightAntenna, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Pixel-Perfect Cover for "The Alchemist"
class _TheAlchemistCover extends StatelessWidget {
  const _TheAlchemistCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE25227),
            Color(0xFFEE8A2B),
            Color(0xFFF9C44E),
            Color(0xFFD64324),
          ],
          stops: [0.0, 0.45, 0.75, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Desert & Sun Art
          CustomPaint(painter: _AlchemistDesertPainter()),
          // Title
          Positioned(
            top: 28,
            left: 8,
            right: 8,
            child: Column(
              children: const [
                Text(
                  'THE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  'ALCHEMIST',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Author at bottom
          Positioned(
            bottom: 10,
            left: 8,
            right: 8,
            child: const Text(
              'Paulo Coelho',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 11,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlchemistDesertPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Glowing Sun
    final sunCenter = Offset(size.width * 0.5, size.height * 0.62);
    final sunPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 14, sunPaint);

    final sunGlow = Paint()
      ..color = const Color(0xFFFFF2A8).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(sunCenter, 26, sunGlow);

    // Desert dunes silhouette
    final dunePaint = Paint()
      ..color = const Color(0xFF8E2818)
      ..style = PaintingStyle.fill;

    final dunePath = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.68, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(dunePath, dunePaint);

    // Solitary traveler silhouette
    final travelerPaint = Paint()
      ..color = const Color(0xFF4A1009)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.70), 2.5, travelerPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.485, size.height * 0.71, 3, 5), travelerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Pixel-Perfect Cover for "The Hobbit"
class _TheHobbitCover extends StatelessWidget {
  const _TheHobbitCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
            Color(0xFF14242B),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Golden portal glow & Bilbo silhouette
          CustomPaint(painter: _HobbitPortalPainter()),
          // Bottom Title
          Positioned(
            bottom: 12,
            left: 6,
            right: 6,
            child: Column(
              children: const [
                Text(
                  'HOBBIT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF7C85C),
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'J.R.R. TOLKIEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF3E7C4),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HobbitPortalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final portalCenter = Offset(size.width * 0.5, size.height * 0.46);

    // Golden circular glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFDE89D),
          const Color(0xFFE89A32),
          const Color(0xFFC0521F).withValues(alpha: 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: portalCenter, radius: 44));
    canvas.drawCircle(portalCenter, 44, glowPaint);

    // Inner arch
    final archPaint = Paint()
      ..color = const Color(0xFFFDEBB2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(portalCenter, 32, archPaint);

    // Bilbo Baggins silhouette
    final bilboPaint = Paint()
      ..color = const Color(0xFF1A1F24)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(portalCenter.dx, portalCenter.dy + 8), 4, bilboPaint);
    // Body / Cloak
    final cloakPath = Path()
      ..moveTo(portalCenter.dx - 4, portalCenter.dy + 12)
      ..lineTo(portalCenter.dx + 4, portalCenter.dy + 12)
      ..lineTo(portalCenter.dx + 9, portalCenter.dy + 28)
      ..lineTo(portalCenter.dx - 9, portalCenter.dy + 28)
      ..close();
    canvas.drawPath(cloakPath, bilboPaint);

    // Walking staff
    final staffPaint = Paint()
      ..color = const Color(0xFF1A1F24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(portalCenter.dx + 8, portalCenter.dy + 6),
      Offset(portalCenter.dx + 8, portalCenter.dy + 30),
      staffPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Pixel-Perfect Cover for "Atomic Habits"
class _AtomicHabitsCover extends StatelessWidget {
  const _AtomicHabitsCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F7F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _AtomicDotsPainter()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Atomic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1C),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Habits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1C),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'An Easy & Proven Way to\nBuild Good Habits & Break Bad Ones',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 6,
                  color: Color(0xFF6F6B62),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'James Clear',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1C),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtomicDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFFD6CEBF)..style = PaintingStyle.fill;
    final center = Offset(size.width * 0.5, size.height * 0.44);

    for (int r = 18; r <= 46; r += 7) {
      final count = (r * 0.9).toInt();
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * 3.14159) / count;
        final dx = center.dx + r * 1.0 * (1 + 0.1 * (i % 3)) * (angle.isNegative ? 1 : 1) * 0.8 * (i % 2 == 0 ? 0.9 : 1.1) * (i.isEven ? 1 : -1);
        final dy = center.dy + r * 0.7 * (i.isOdd ? 1 : -1);
        if (dx >= 4 && dx <= size.width - 4 && dy >= 4 && dy <= size.height - 4) {
          canvas.drawCircle(Offset(dx, dy), (i % 3 == 0) ? 1.0 : 0.6, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Pixel-Perfect Cover for "Dune"
class _DuneCover extends StatelessWidget {
  const _DuneCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091428),
            Color(0xFF122340),
            Color(0xFF261D3B),
            Color(0xFF0A0E1A),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _DuneArtPainter()),
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: const Text(
              'D U N E',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF6A63B),
                letterSpacing: 4.0,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: const Text(
              'FRANK HERBERT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE5DDD0),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuneArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Giant glowing crescent moon
    final moonCenter = Offset(size.width * 0.5, size.height * 0.48);
    final moonPaint = Paint()
      ..color = const Color(0xFFF99D26)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(moonCenter, 24, moonPaint);

    final shadowMoon = Paint()
      ..color = const Color(0xFF0F1E38)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(moonCenter.dx - 8, moonCenter.dy - 6), 22, shadowMoon);

    // Undulating desert dunes
    final dunePaint = Paint()
      ..color = const Color(0xFFBD6520)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.70)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.62, size.width * 0.7, size.height * 0.73)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.78, size.width, size.height * 0.74)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, dunePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Pixel-Perfect Cover for "Think Again"
class _ThinkAgainCover extends StatelessWidget {
  const _ThinkAgainCover();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'THINK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF141414),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'AGAIN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF141414),
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'ADAM GRANT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFBA7822),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

