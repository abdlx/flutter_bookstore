import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book_model.dart';
import '../services/book_service.dart';

final bookServiceProvider = Provider((ref) => BookService());

final booksProvider = StreamProvider<List<Book>>(
  (ref) => ref.watch(bookServiceProvider).watchBooks(),
);
