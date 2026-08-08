import '../../../src/network/api_client.dart';
import '../../../src/network/api_endpoints.dart';
import '../models/history.dart';
import '../models/order.dart';
import '../models/orders_feed.dart';
import 'orders_repository.dart';

class RemoteOrdersRepository implements OrdersRepository {
  RemoteOrdersRepository({required ApiClient api}) : _api = api;

  final ApiClient _api;

  @override
  Future<OrdersFeed> fetchOrdersFeed() async {
    final active = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.orders,
      parser: _asList,
    );
    final historyRaw = await _api.get<List<Map<String, dynamic>>>(
      ApiEndpoints.ordersHistory,
      parser: _asList,
    );

    final activeOrders = active.map(_mapOrder).toList();
    final history = historyRaw.map((e) {
      final order = _mapOrder(e);
      return History.fromOrder(order);
    }).toList();

    return OrdersFeed(activeOrders: activeOrders, history: history);
  }

  @override
  Future<List<History>> fetchOrderHistory() async {
    final feed = await fetchOrdersFeed();
    return feed.history;
  }

  @override
  Future<Order> fetchOrderById(String orderId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.order(orderId),
      parser: _asMap,
    );
    return _mapOrder(data);
  }

  @override
  Future<OrderTracking> fetchTracking(String orderId) async {
    final data = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.orderTrack(orderId),
      parser: _asMap,
    );
    final order = _mapOrder(data);
    return order.tracking ??
        OrderTracking(
          orderId: order.id,
          courierName: order.tracking?.courierName ?? data['courier_name'] as String?,
          trackingNumber:
              order.tracking?.trackingNumber ?? data['tracking_number'] as String?,
          currentStatus: order.status,
          events: order.tracking?.events ?? const [],
        );
  }

  @override
  Future<Order> createOrder(Order order) async {
    // Checkout already creates server orders; return the remote copy if possible.
    try {
      return await fetchOrderById(order.id);
    } catch (_) {
      return order;
    }
  }

  Order _mapOrder(Map<String, dynamic> json) {
    final trackingEvents = json['tracking_events'];
    final mapped = Map<String, dynamic>.from(json);
    if (trackingEvents is List && json['tracking'] == null) {
      mapped['tracking'] = {
        'order_id': json['id'],
        'courier_name': json['courier_name'],
        'tracking_number': json['tracking_number'],
        'current_status': json['status'],
        'events': trackingEvents,
      };
    }
    if (json['address'] is Map && json['shipping_address_label'] == null) {
      final address = Map<String, dynamic>.from(json['address'] as Map);
      mapped['shipping_address_label'] = [
        address['line1'],
        address['city'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
    }
    return Order.fromJson(mapped);
  }

  List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
