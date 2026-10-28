import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../data/firestore/firestore_media_repository.dart';

final _mediaProvider = FutureProvider.autoDispose.family<Uint8List, String>((
  ref,
  id,
) async {
  if (!RegExp(r'^[A-Za-z0-9]{20}$').hasMatch(id)) {
    throw StateError('Invalid image reference.');
  }
  final doc = await ref
      .watch(firebaseFirestoreProvider)
      .collection('media')
      .doc(id)
      .get();
  if (!doc.exists) throw StateError('Image no longer available.');
  return base64Decode(doc.data()!['data'] as String);
});

class StoreImage extends ConsumerWidget {
  final String url;
  final double? width, height;
  final BoxFit fit;
  final Widget fallback;
  final Widget? loading;
  const StoreImage({
    super.key,
    required this.url,
    required this.fallback,
    this.loading,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (url.startsWith(mediaPrefix)) {
      return ref
          .watch(_mediaProvider(url.substring(mediaPrefix.length)))
          .when(
            data: (bytes) => Image.memory(
              bytes,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => fallback,
            ),
            loading: () => loading ?? fallback,
            error: (_, _) => fallback,
          );
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return fallback;
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => loading ?? fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
