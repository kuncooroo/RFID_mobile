import '../models/history.dart';
import '../models/order.dart';
import '../models/orders_feed.dart';
import 'mock_orders_repository.dart';
import 'orders_repository.dart';

/// Local orders stand-in until Laravel order endpoints are wired.
class LocalOrdersRepository implements OrdersRepository {
  LocalOrdersRepository({MockOrdersRepository? delegate})
      : _delegate = delegate ?? MockOrdersRepository.shared;

  final MockOrdersRepository _delegate;

  @override
  Future<OrdersFeed> fetchOrdersFeed() => _delegate.fetchOrdersFeed();

  @override
  Future<List<History>> fetchOrderHistory() => _delegate.fetchOrderHistory();

  @override
  Future<Order> fetchOrderById(String orderId) =>
      _delegate.fetchOrderById(orderId);

  @override
  Future<OrderTracking> fetchTracking(String orderId) =>
      _delegate.fetchTracking(orderId);

  @override
  Future<Order> createOrder(Order order) => _delegate.createOrder(order);
}
