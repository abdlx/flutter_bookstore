import '../../core/models/book.dart';
import '../../core/models/order.dart';
import '../../core/models/user_profile.dart';

class AdminDashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalBooks;
  final int totalUsers;
  final double growthRate;

  const AdminDashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalBooks,
    required this.totalUsers,
    this.growthRate = 14.8,
  });
}

abstract class AdminRepository {
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<OrderItem>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<List<UserProfile>> getAllUsers();
  Future<void> updateUserRole(String userId, UserRole role);
  Future<List<BookItem>> getAllBooks();
  Future<void> saveBook(BookItem book);
  Future<void> deleteBook(String bookId);
}
