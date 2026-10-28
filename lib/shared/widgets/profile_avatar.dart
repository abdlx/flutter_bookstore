import 'store_image.dart';

import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class ProfileAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  const ProfileAvatar({super.key, this.url, this.radius = 24});
  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.person_outline,
      size: radius,
      color: BookstoreTokens.primaryDark,
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: BookstoreTokens.surfaceWarm,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: StoreImage(
            url: url ?? '',
            fallback: Center(child: fallback),
          ),
        ),
      ),
    );
  }
}
