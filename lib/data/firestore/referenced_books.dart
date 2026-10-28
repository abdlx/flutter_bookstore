import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/models/book.dart';
import 'firestore_codec.dart';

class ReferencedBooks {
  final FirebaseFirestore db;
  final void Function(Map<String, BookItem>) onData;
  final void Function(Object) onError;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  int _generation = 0;
  bool _disposed = false;
  ReferencedBooks(this.db, {required this.onData, required this.onError});
  Future<void> watch(Iterable<String> values) async {
    if (_disposed) return;
    final generation = ++_generation;
    final previous = _subscriptions.toList();
    _subscriptions.clear();
    await Future.wait(previous.map((s) => s.cancel()));
    if (_disposed || generation != _generation) return;
    final ids = values.toSet().toList();
    if (ids.isEmpty) {
      onData({});
      return;
    }
    final chunks = <int, Map<String, BookItem>>{};
    final total = (ids.length / 30).ceil();
    for (var i = 0; i < total; i++) {
      final index = i;
      final end = (i + 1) * 30 > ids.length ? ids.length : (i + 1) * 30;
      _subscriptions.add(
        db
            .collection('books')
            .where(FieldPath.documentId, whereIn: ids.sublist(i * 30, end))
            .snapshots()
            .listen(
              (s) {
                if (generation != _generation) return;
                chunks[index] = {
                  for (final d in s.docs) d.id: readBook(d.id, d.data()),
                };
                if (chunks.length == total) {
                  onData({for (final chunk in chunks.values) ...chunk});
                }
              },
              onError: (Object e) {
                if (generation == _generation) onError(e);
              },
            ),
      );
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();
  }
}
