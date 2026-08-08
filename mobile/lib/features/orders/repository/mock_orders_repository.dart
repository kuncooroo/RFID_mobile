import '../models/history.dart';
import '../models/order.dart';
import '../models/orders_feed.dart';
import 'orders_repository.dart';

/// Seeded orders repository for tests and UI demos.
///
/// Uses a shared in-memory list so Local + Checkout both see the same orders.
class MockOrdersRepository implements OrdersRepository {
  MockOrdersRepository({
    this.delay = const Duration(milliseconds: 400),
    this.shouldFail = false,
    List<Order>? seed,
  }) {
    _sharedOrders ??= List<Order>.from(seed ?? _seedOrders);
  }

  /// Shared singleton used by [LocalOrdersRepository] and checkout wiring.
  static final MockOrdersRepository shared = MockOrdersRepository();

  final Duration delay;
  final bool shouldFail;

  static List<Order>? _sharedOrders;

  List<Order> get _orders => _sharedOrders!;

  /// Test helper — resets shared seed data.
  static void resetShared({List<Order>? seed}) {
    _sharedOrders = List<Order>.from(seed ?? _seedOrders);
  }

  @override
  Future<OrdersFeed> fetchOrdersFeed() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load orders');

    final active = _orders.where((o) => o.isActive).toList();
    final history = _orders
        .where((o) => o.isHistory)
        .map(History.fromOrder)
        .toList();

    return OrdersFeed(activeOrders: active, history: history);
  }

  @override
  Future<List<History>> fetchOrderHistory() async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load order history');
    return _orders.where((o) => o.isHistory).map(History.fromOrder).toList();
  }

  @override
  Future<Order> fetchOrderById(String orderId) async {
    await Future<void>.delayed(delay);
    if (shouldFail) throw StateError('Unable to load order');
    return _orders.firstWhere(
      (o) => o.id == orderId || o.orderNumber == orderId,
      orElse: () => throw StateError('Order not found'),
    );
  }

  @override
  Future<OrderTracking> fetchTracking(String orderId) async {
    final order = await fetchOrderById(orderId);
    final tracking = order.tracking;
    if (tracking == null) {
      throw StateError('Tracking is not available for this order');
    }
    return tracking;
  }

  @override
  Future<Order> createOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (shouldFail) throw StateError('Unable to create order');

    final existingIndex = _orders.indexWhere((o) => o.id == order.id);
    if (existingIndex >= 0) {
      _orders[existingIndex] = order;
    } else {
      _orders.insert(0, order);
    }
    return order;
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (shouldFail) throw StateError('Unable to cancel order');
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) throw StateError('Order not found');
    final current = _orders[index];
    if (!current.canCancel) {
      throw StateError('Order cannot be cancelled');
    }
    final cancelled = current.copyWith(
      status: OrderStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    _orders[index] = cancelled;
    return cancelled;
  }
}

final _now = DateTime.now();

final _seedOrders = <Order>[
  Order(
    id: 'ord-1042',
    orderNumber: 'KU-1042',
    status: OrderStatus.shipped,
    total: 186,
    subtotal: 168,
    shippingFee: 18,
    currency: 'USD',
    shippingAddressLabel:
        'Alex Morgan · 742 Evergreen Terrace, Springfield, IL 62704',
    placedAt: _now.subtract(const Duration(days: 2)),
    updatedAt: _now.subtract(const Duration(hours: 5)),
    items: const [
      OrderItem(
        id: 'oi-1',
        productId: 'p1',
        name: 'Quilted Mini Bag',
        unitPrice: 128,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/kutuku-p1/200/200',
        variantLabel: 'Black',
      ),
      OrderItem(
        id: 'oi-2',
        productId: 'p4',
        name: 'Silk Scarf',
        unitPrice: 40,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/kutuku-p4/200/200',
        variantLabel: 'Ivory',
      ),
    ],
    tracking: OrderTracking(
      orderId: 'ord-1042',
      courierName: 'J&T Express',
      trackingNumber: 'JT99881234',
      currentStatus: OrderStatus.shipped,
      events: [
        OrderTrackingEvent(
          id: 'e1',
          title: 'Order placed',
          description: 'We received your order',
          occurredAt: _now.subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e2',
          title: 'Payment confirmed',
          description: 'Payment was successful',
          occurredAt: _now.subtract(const Duration(days: 2)).add(
                const Duration(hours: 1),
              ),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e3',
          title: 'Packed & ready',
          description: 'Package prepared by warehouse',
          occurredAt: _now.subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e4',
          title: 'On the way',
          description: 'Courier picked up your package',
          occurredAt: _now.subtract(const Duration(hours: 5)),
          isCompleted: true,
        ),
        const OrderTrackingEvent(
          id: 'e5',
          title: 'Delivered',
          description: 'Package delivered to your address',
          isCompleted: false,
        ),
      ],
    ),
  ),
  Order(
    id: 'ord-1039',
    orderNumber: 'KU-1039',
    status: OrderStatus.processing,
    total: 96,
    subtotal: 96,
    shippingFee: 0,
    currency: 'USD',
    shippingAddressLabel:
        'Alex Morgan · 742 Evergreen Terrace, Springfield, IL 62704',
    placedAt: _now.subtract(const Duration(days: 1)),
    updatedAt: _now.subtract(const Duration(hours: 12)),
    items: const [
      OrderItem(
        id: 'oi-3',
        productId: 'p3',
        name: 'City Runner Sneakers',
        unitPrice: 96,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/kutuku-p3/200/200',
        variantLabel: '42 / White',
      ),
    ],
    tracking: OrderTracking(
      orderId: 'ord-1039',
      courierName: 'SiCepat',
      trackingNumber: 'SC445566',
      currentStatus: OrderStatus.processing,
      events: [
        OrderTrackingEvent(
          id: 'e1',
          title: 'Order placed',
          occurredAt: _now.subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e2',
          title: 'Processing',
          description: 'Seller is preparing your items',
          occurredAt: _now.subtract(const Duration(hours: 12)),
          isCompleted: true,
        ),
        const OrderTrackingEvent(
          id: 'e3',
          title: 'Shipped',
          isCompleted: false,
        ),
        const OrderTrackingEvent(
          id: 'e4',
          title: 'Delivered',
          isCompleted: false,
        ),
      ],
    ),
  ),
  Order(
    id: 'ord-1031',
    orderNumber: 'KU-1031',
    status: OrderStatus.delivered,
    total: 145,
    subtotal: 145,
    shippingFee: 0,
    currency: 'USD',
    shippingAddressLabel:
        'Alex Morgan · 100 Market Street, Suite 400, San Francisco, CA 94105',
    placedAt: _now.subtract(const Duration(days: 12)),
    updatedAt: _now.subtract(const Duration(days: 8)),
    items: const [
      OrderItem(
        id: 'oi-4',
        productId: 'p7',
        name: 'Chelsea Boots',
        unitPrice: 145,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/kutuku-p7/200/200',
      ),
    ],
    tracking: OrderTracking(
      orderId: 'ord-1031',
      courierName: 'J&T Express',
      trackingNumber: 'JT11002233',
      currentStatus: OrderStatus.delivered,
      events: [
        OrderTrackingEvent(
          id: 'e1',
          title: 'Order placed',
          occurredAt: _now.subtract(const Duration(days: 12)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e2',
          title: 'Shipped',
          occurredAt: _now.subtract(const Duration(days: 10)),
          isCompleted: true,
        ),
        OrderTrackingEvent(
          id: 'e3',
          title: 'Delivered',
          description: 'Package delivered to your address',
          occurredAt: _now.subtract(const Duration(days: 8)),
          isCompleted: true,
        ),
      ],
    ),
  ),
  Order(
    id: 'ord-1022',
    orderNumber: 'KU-1022',
    status: OrderStatus.cancelled,
    total: 58,
    currency: 'USD',
    placedAt: _now.subtract(const Duration(days: 20)),
    updatedAt: _now.subtract(const Duration(days: 19)),
    items: const [
      OrderItem(
        id: 'oi-5',
        productId: 'p8',
        name: 'Linen Shirt',
        unitPrice: 58,
        quantity: 1,
        imageUrl: 'https://picsum.photos/seed/kutuku-p8/200/200',
      ),
    ],
  ),
];
