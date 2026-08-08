import 'order.dart';

/// Completed / past order list entry for My Order History.
class History {
  const History({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.total,
    this.itemCount = 0,
    this.thumbnailUrl,
    this.completedAt,
    this.currency = 'USD',
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final OrderStatus status;
  final double total;
  final int itemCount;
  final String? thumbnailUrl;
  final DateTime? completedAt;
  final String currency;

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'].toString(),
      orderId: json['order_id']?.toString() ?? json['id'].toString(),
      orderNumber: json['order_number'] as String? ?? '',
      status: OrderStatus.fromJson(json['status'] as String?),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'order_number': orderNumber,
      'status': status.toJson(),
      'total': total,
      'item_count': itemCount,
      'thumbnail_url': thumbnailUrl,
      'completed_at': completedAt?.toIso8601String(),
      'currency': currency,
    };
  }

  /// Builds a history row from a completed [Order].
  factory History.fromOrder(Order order) {
    return History(
      id: order.id,
      orderId: order.id,
      orderNumber: order.orderNumber,
      status: order.status,
      total: order.total,
      itemCount: order.items.fold(0, (s, i) => s + i.quantity),
      thumbnailUrl: order.items.isNotEmpty ? order.items.first.imageUrl : null,
      completedAt: order.updatedAt ?? order.placedAt,
      currency: order.currency,
    );
  }
}
