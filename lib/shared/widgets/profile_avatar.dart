import 'package:flutter/material.dart';

import '../../core/theme/bookstore_tokens.dart';

class ProfileAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  const ProfileAvatar({super.key, this.url, this.radius = 24});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: BookstoreTokens.surfaceWarm,
    child: url == null || url!.isEmpty
        ? Icon(
            Icons.person_outline,
            size: radius,
            color: BookstoreTokens.primaryDark,
          )
        : ClipOval(
            child: Image.network(
              url!,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.person_outline,
                size: radius,
                color: BookstoreTokens.primaryDark,
              ),
            ),
          ),
  );
}
