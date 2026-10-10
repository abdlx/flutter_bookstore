import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String coverUrl;
  final double price;
  final double rating;
  final int ratingCount;
  final int popularity;
  final bool isBestseller;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.coverUrl,
    required this.price,
    this.rating = 0,
    this.ratingCount = 0,
    this.popularity = 0,
    this.isBestseller = false,
    required this.createdAt,
  });

  factory Book.fromMap(String id, Map<String, dynamic> m) => Book(
    id: id,
    title: m['title'] ?? '',
    author: m['author'] ?? '',
    genre: m['genre'] ?? '',
    description: m['description'] ?? '',
    coverUrl: m['coverUrl'] ?? '',
    price: (m['price'] ?? 0).toDouble(),
    rating: (m['rating'] ?? 0).toDouble(),
    ratingCount: m['ratingCount'] ?? 0,
    popularity: m['popularity'] ?? 0,
    isBestseller: m['isBestseller'] ?? false,
    createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'genre': genre,
    'description': description,
    'coverUrl': coverUrl,
    'price': price,
    'rating': rating,
    'ratingCount': ratingCount,
    'popularity': popularity,
    'isBestseller': isBestseller,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
