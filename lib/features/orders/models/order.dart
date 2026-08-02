/// Purchase order from My Order / History / Track screens.
class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    this.items = const [],
    this.currency = 'USD',
    this.subtotal,
    this.shippingFee,
    this.discount,
    this.addressId,
    this.paymentMethodId,
    this.placedAt,
    this.updatedAt,
    this.tracking,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;
  final String currency;
  final double? subtotal;
  final double? shippingFee;
  final double? discount;
  final String? addressId;
  final String? paymentMethodId;
  final DateTime? placedAt;
  final DateTime? updatedAt;
  final OrderTracking? tracking;

  bool get isActive =>
      status == OrderStatus.pending ||
      status == OrderStatus.paid ||
      status == OrderStatus.processing ||
      status == OrderStatus.shipped;

  bool get isHistory =>
      status == OrderStatus.delivered ||
      status == OrderStatus.cancelled ||
      status == OrderStatus.refunded;

  Order copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    double? total,
    List<OrderItem>? items,
    String? currency,
    double? subtotal,
    double? shippingFee,
    double? discount,
    String? addressId,
    String? paymentMethodId,
    DateTime? placedAt,
    DateTime? updatedAt,
    OrderTracking? tracking,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      total: total ?? this.total,
      items: items ?? this.items,
      currency: currency ?? this.currency,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      addressId: addressId ?? this.addressId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      placedAt: placedAt ?? this.placedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tracking: tracking ?? this.tracking,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final trackingJson = json['tracking'];

    return Order(
      id: json['id'].toString(),
      orderNumber:
          json['order_number'] as String? ??
          json['number'] as String? ??
          json['id'].toString(),
      status: OrderStatus.fromJson(json['status'] as String?),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      items: itemsJson is List
          ? itemsJson
                .whereType<Map>()
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
      currency: json['currency'] as String? ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      shippingFee: (json['shipping_fee'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      addressId: json['address_id']?.toString(),
      paymentMethodId: json['payment_method_id']?.toString(),
      placedAt: json['placed_at'] != null
          ? DateTime.tryParse(json['placed_at'].toString())
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'].toString())
                : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      tracking: trackingJson is Map
          ? OrderTracking.fromJson(Map<String, dynamic>.from(trackingJson))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status.toJson(),
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
      'currency': currency,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'address_id': addressId,
      'payment_method_id': paymentMethodId,
      'placed_at': placedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'tracking': tracking?.toJson(),
    };
  }
}

enum OrderStatus {
  pending,
  paid,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded;

  static OrderStatus fromJson(String? value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String toJson() => name;

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.paid => 'Paid',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
    OrderStatus.refunded => 'Refunded',
  };
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.variantLabel,
  });

  final String id;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final String? variantLabel;

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name: json['name'] as String? ?? '',
      unitPrice:
          (json['unit_price'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: json['image_url'] as String?,
      variantLabel: json['variant_label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'unit_price': unitPrice,
      'quantity': quantity,
      'image_url': imageUrl,
      'variant_label': variantLabel,
    };
  }
}

/// Shipment tracking timeline for Order Track screen.
class OrderTracking {
  const OrderTracking({
    required this.orderId,
    this.courierName,
    this.trackingNumber,
    this.currentStatus,
    this.events = const [],
  });

  final String orderId;
  final String? courierName;
  final String? trackingNumber;
  final OrderStatus? currentStatus;
  final List<OrderTrackingEvent> events;

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'];
    return OrderTracking(
      orderId: json['order_id']?.toString() ?? '',
      courierName: json['courier_name'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      currentStatus: OrderStatus.fromJson(json['current_status'] as String?),
      events: eventsJson is List
          ? eventsJson
                .whereType<Map>()
                .map(
                  (e) =>
                      OrderTrackingEvent.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'courier_name': courierName,
      'tracking_number': trackingNumber,
      'current_status': currentStatus?.toJson(),
      'events': events.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderTrackingEvent {
  const OrderTrackingEvent({
    required this.id,
    required this.title,
    this.description,
    this.occurredAt,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? occurredAt;
  final bool isCompleted;

  factory OrderTrackingEvent.fromJson(Map<String, dynamic> json) {
    return OrderTrackingEvent(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      occurredAt: json['occurred_at'] != null
          ? DateTime.tryParse(json['occurred_at'].toString())
          : null,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'occurred_at': occurredAt?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
