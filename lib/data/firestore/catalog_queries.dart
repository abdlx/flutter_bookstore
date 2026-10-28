import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/book.dart';
import 'firestore_codec.dart';

String normalizeSearch(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
    .trim();
List<String> searchTokens(BookItem book) {
  final words = normalizeSearch(
    '${book.title} ${book.author} ${book.genre} ${book.tags.join(' ')}',
  ).split(' ');
  final tokens = <String>{};
  for (final word in words.take(100)) {
    for (var i = 1; i <= word.length && i <= 32; i++) {
      tokens.add(word.substring(0, i));
    }
  }
  return tokens.take(1600).toList();
}

Query<Map<String, dynamic>> catalogQuery(
  FirebaseFirestore db, {
  String keyword = '',
  String genre = 'All',
  String sort = 'popular',
}) {
  Query<Map<String, dynamic>> query = db.collection('books');
  final words = normalizeSearch(keyword)
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isNotEmpty) {
    query = query.where(
      'searchTokens',
      arrayContains: words.first.substring(
        0,
        words.first.length > 32 ? 32 : words.first.length,
      ),
    );
  }
  if (genre != 'All') query = query.where('genre', isEqualTo: genre);
  final field = switch (sort) {
    'price_low' || 'price_high' => 'price',
    'rating' => 'ratingScore',
    'newest' => 'publishedDate',
    _ => 'reviewTotal',
  };
  return query
      .orderBy(field, descending: !['price_low'].contains(sort))
      .orderBy(FieldPath.documentId, descending: !['price_low'].contains(sort));
}

bool matchesCatalog(BookItem book, String keyword, double? maxPrice) {
  final text = normalizeSearch(
    '${book.title} ${book.author} ${book.genre} ${book.tags.join(' ')}',
  );
  return (maxPrice == null || book.price <= maxPrice) &&
      normalizeSearch(keyword).split(' ').every((word) => text.contains(word));
}

Future<void> saveCatalogBook(FirebaseFirestore db, BookItem book) async {
  final ref = db.collection('books').doc(book.id),
      metadata = db.doc('catalog/metadata');
  await db.runTransaction((tx) async {
    final old = await tx.get(ref), meta = await tx.get(metadata);
    final genres = Map<String, dynamic>.from(
      meta.data()?['genreCounts'] as Map? ?? {},
    );
    final oldGenre = old.data()?['genre'] as String?;
    if (oldGenre != book.genre) {
      if (oldGenre != null) {
        genres[oldGenre] = ((genres[oldGenre] as num? ?? 1).toInt() - 1).clamp(
          0,
          1 << 31,
        );
      }
      genres[book.genre] = (genres[book.genre] as num? ?? 0).toInt() + 1;
    }
    final data = book.toMap()
      ..remove('rating')
      ..remove('reviewCount')
      ..remove('ratingBreakdown');
    data['searchTokens'] = searchTokens(book);
    // Separate sortable fields exist even before the first review.
    if (!old.exists) {
      data['ratingScore'] = 0;
      data['reviewTotal'] = 0;
    }
    tx.set(ref, data, SetOptions(merge: true));
    tx.set(metadata, {
      'genreCounts': genres,
      'genres':
          genres.entries
              .where((e) => (e.value as num) > 0)
              .map((e) => e.key)
              .toList()
            ..sort(),
    });
  });
}

Future<void> deleteCatalogBook(FirebaseFirestore db, String id) async {
  final ref = db.collection('books').doc(id),
      metadata = db.doc('catalog/metadata');
  await db.runTransaction((tx) async {
    final old = await tx.get(ref), meta = await tx.get(metadata);
    if (!old.exists) return;
    final genres = Map<String, dynamic>.from(
      meta.data()?['genreCounts'] as Map? ?? {},
    );
    final genre = old.data()!['genre'] as String;
    genres[genre] = ((genres[genre] as num? ?? 1).toInt() - 1).clamp(
      0,
      1 << 31,
    );
    tx.delete(ref);
    tx.set(metadata, {
      'genreCounts': genres,
      'genres':
          genres.entries
              .where((e) => (e.value as num) > 0)
              .map((e) => e.key)
              .toList()
            ..sort(),
    });
  });
}

Stream<List<BookItem>> watchHomeBooks(FirebaseFirestore db, String genre) {
  late StreamController<List<BookItem>> controller;
  final subscriptions = <StreamSubscription<dynamic>>[];
  final feeds = <int, List<BookItem>>{};
  final queries = genre == 'All'
      ? [
          db
              .collection('books')
              .where('isRecommended', isEqualTo: true)
              .limit(12),
          db
              .collection('books')
              .where('isBestseller', isEqualTo: true)
              .limit(12),
          db
              .collection('books')
              .orderBy('publishedDate', descending: true)
              .limit(12),
        ]
      : [db.collection('books').where('genre', isEqualTo: genre).limit(36)];
  controller = StreamController(
    onListen: () {
      for (var i = 0; i < queries.length; i++) {
        final index = i;
        subscriptions.add(
          queries[i].snapshots().listen((s) {
            feeds[index] = s.docs.map((d) => readBook(d.id, d.data())).toList();
            if (feeds.length == queries.length) {
              controller.add(
                {
                  for (final feed in feeds.values)
                    for (final book in feed) book.id: book,
                }.values.toList(),
              );
            }
          }, onError: controller.addError),
        );
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );
  return controller.stream;
}
