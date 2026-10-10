import '../../core/models/book.dart';
import '../../core/models/order.dart';
import '../../core/models/user_profile.dart';
import '../contracts/admin_repository.dart';
import 'mock_database.dart';

class MockAdminRepository implements AdminRepository {
  final MockDatabase _db = MockDatabase.instance;

  @override
  Future<AdminDashboardStats> getDashboardStats() async {
    final revenue = _db.orders.fold(0.0, (sum, o) => sum + o.total);
    return AdminDashboardStats(
      totalRevenue: revenue > 0 ? revenue : 12450.0,
      totalOrders: _db.orders.length + 142,
      totalBooks: _db.books.length,
      totalUsers: _db.allUsers.length + 320,
      growthRate: 18.4,
    );
  }

  @override
  Future<List<OrderItem>> getAllOrders() async {
    return List.unmodifiable(_db.orders);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final index = _db.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _db.orders[index] = _db.orders[index].copyWith(status: status);
    }
  }

  @override
  Future<List<UserProfile>> getAllUsers() async {
    return List.unmodifiable(_db.allUsers);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    final index = _db.allUsers.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _db.allUsers[index] = _db.allUsers[index].copyWith(role: role);
    }
  }

  @override
  Future<List<BookItem>> getAllBooks() async {
    return List.unmodifiable(_db.books);
  }

  @override
  Future<void> saveBook(BookItem book) async {
    final index = _db.books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _db.books[index] = book;
    } else {
      _db.books.insert(0, book);
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    _db.books.removeWhere((b) => b.id == bookId);
  }
}
