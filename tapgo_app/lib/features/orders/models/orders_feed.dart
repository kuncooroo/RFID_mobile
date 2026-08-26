import 'history.dart';
import 'order.dart';

/// Aggregated My Order feed (active + history).
class OrdersFeed {
  const OrdersFeed({this.activeOrders = const [], this.history = const []});

  final List<Order> activeOrders;
  final List<History> history;

  bool get isEmpty => activeOrders.isEmpty && history.isEmpty;

  int get activeCount => activeOrders.length;

  OrdersFeed copyWith({List<Order>? activeOrders, List<History>? history}) {
    return OrdersFeed(
      activeOrders: activeOrders ?? this.activeOrders,
      history: history ?? this.history,
    );
  }
}
