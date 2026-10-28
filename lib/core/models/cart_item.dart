import 'book.dart';

class CartItem {
  final String id;
  final BookItem book;
  final int quantity;

  const CartItem({required this.id, required this.book, this.quantity = 1});

  double get unitPrice => (book.price * 100).round() / 100;
  double get totalPrice => (unitPrice * 100).round() * quantity / 100;

  CartItem copyWith({String? id, BookItem? book, int? quantity}) {
    return CartItem(
      id: id ?? this.id,
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
    );
  }
}
