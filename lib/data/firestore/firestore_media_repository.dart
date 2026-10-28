import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';

const mediaPrefix = 'firestore-media://';

class FirestoreMediaRepository {
  final FirebaseFirestore db;
  final String? uid;
  FirestoreMediaRepository(this.db, this.uid);
  Future<String> upload(Uint8List input, {required String purpose}) async {
    if (uid == null) {
      throw StateError('Please sign in before uploading an image.');
    }
    if (!['avatar', 'cover'].contains(purpose)) {
      throw ArgumentError('Invalid image purpose.');
    }
    final bytes = await prepareStoreImage(input);
    final ref = db.collection('media').doc();
    await ref.set({
      'ownerId': uid,
      'purpose': purpose,
      'contentType': 'image/png',
      'data': base64Encode(bytes),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return '$mediaPrefix${ref.id}';
  }
}

Future<Uint8List> prepareStoreImage(Uint8List input) async {
  if (input.isEmpty || input.length > 10 * 1024 * 1024) {
    throw ArgumentError('Choose an image smaller than 10 MB.');
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(input);
  ui.ImageDescriptor? descriptor;
  try {
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    var longest = math.min(768, math.max(descriptor.width, descriptor.height));
    while (longest > 0) {
      final scale = longest / math.max(descriptor.width, descriptor.height);
      final codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * scale).round()),
        targetHeight: math.max(1, (descriptor.height * scale).round()),
      );
      ui.Image? image;
      try {
        image = (await codec.getNextFrame()).image;
        final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
        final output = encoded!.buffer.asUint8List(
          encoded.offsetInBytes,
          encoded.lengthInBytes,
        );
        if (output.length <= 450000) return output;
      } finally {
        image?.dispose();
        codec.dispose();
      }
      if (longest <= 96) break;
      longest = (longest * 0.75).floor();
    }
    throw StateError(
      'This image cannot be resized for upload. Choose another image.',
    );
  } finally {
    descriptor?.dispose();
    buffer.dispose();
  }
}
