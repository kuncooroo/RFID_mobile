import '../models/history.dart';
import '../models/order.dart';
import '../models/orders_feed.dart';

/// Contract for My Order / History / Track data.
abstract class OrdersRepository {
  Future<OrdersFeed> fetchOrdersFeed();

  Future<List<History>> fetchOrderHistory();

  Future<Order> fetchOrderById(String orderId);

  Future<OrderTracking> fetchTracking(String orderId);
}
