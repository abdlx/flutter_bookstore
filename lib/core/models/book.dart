class BookItem {
  final String id;
  final String title;
  final String author;
  final String genre;
  final List<String> tags;
  final String description;
  final String coverUrl;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final Map<int, double> ratingBreakdown; // Star value to review fraction.
  final bool isBestseller;
  final bool isRecommended;
  final String format; // 'Paperback'
  final int pages; // 320
  final String language; // 'English'
  final String publisher; // 'Andrews McMeel'
  final int stockQuantity;
  final DateTime publishedDate;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    this.tags = const [],
    required this.description,
    required this.coverUrl,
    required this.price,
    this.originalPrice,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.ratingBreakdown = const {},
    this.isBestseller = false,
    this.isRecommended = false,
    this.format = '',
    this.pages = 0,
    this.language = '',
    this.publisher = '',
    this.stockQuantity = 0,
    required this.publishedDate,
  });

  BookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    List<String>? tags,
    String? description,
    String? coverUrl,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    Map<int, double>? ratingBreakdown,
    bool? isBestseller,
    bool? isRecommended,
    String? format,
    int? pages,
    String? language,
    String? publisher,
    int? stockQuantity,
    DateTime? publishedDate,
  }) {
    return BookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      isBestseller: isBestseller ?? this.isBestseller,
      isRecommended: isRecommended ?? this.isRecommended,
      format: format ?? this.format,
      pages: pages ?? this.pages,
      language: language ?? this.language,
      publisher: publisher ?? this.publisher,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      publishedDate: publishedDate ?? this.publishedDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'genre': genre,
    'tags': tags,
    'description': description,
    'coverUrl': coverUrl,
    'price': price,
    'originalPrice': originalPrice,
    'rating': rating,
    'reviewCount': reviewCount,
    'ratingBreakdown': ratingBreakdown.map(
      (key, value) => MapEntry(key.toString(), value),
    ),
    'isBestseller': isBestseller,
    'isRecommended': isRecommended,
    'format': format,
    'pages': pages,
    'language': language,
    'publisher': publisher,
    'stockQuantity': stockQuantity,
    'publishedDate': publishedDate.toIso8601String(),
  };

  factory BookItem.fromMap(Map<String, dynamic> map) => BookItem(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    author: map['author'] ?? '',
    genre: map['genre'] ?? '',
    tags: List<String>.from(map['tags'] ?? []),
    description: map['description'] ?? '',
    coverUrl: map['coverUrl'] ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    originalPrice: (map['originalPrice'] as num?)?.toDouble(),
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
    ratingBreakdown: (map['ratingBreakdown'] as Map? ?? {}).map(
      (key, value) =>
          MapEntry(int.parse(key.toString()), (value as num).toDouble()),
    ),
    isBestseller: map['isBestseller'] ?? false,
    isRecommended: map['isRecommended'] ?? false,
    format: map['format'] ?? '',
    pages: (map['pages'] as num?)?.toInt() ?? 0,
    language: map['language'] ?? '',
    publisher: map['publisher'] ?? '',
    stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
    publishedDate: map['publishedDate'] != null
        ? DateTime.tryParse(map['publishedDate'].toString()) ??
              DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(0),
  );
}
