import '../models/history.dart';
import '../models/order.dart';
import '../models/orders_feed.dart';

enum OrdersSegment { active, history }

enum OrdersStatus { initial, loading, refreshing, ready, failure }

class OrdersState {
  const OrdersState({
    this.status = OrdersStatus.initial,
    this.feed = const OrdersFeed(),
    this.segment = OrdersSegment.active,
    this.errorMessage,
  });

  const OrdersState.initial() : this();

  final OrdersStatus status;
  final OrdersFeed feed;
  final OrdersSegment segment;
  final String? errorMessage;

  bool get isLoading =>
      status == OrdersStatus.initial || status == OrdersStatus.loading;

  bool get isRefreshing => status == OrdersStatus.refreshing;

  bool get hasFailed => status == OrdersStatus.failure;

  bool get isReady =>
      status == OrdersStatus.ready || status == OrdersStatus.refreshing;

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersFeed? feed,
    OrdersSegment? segment,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      segment: segment ?? this.segment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum OrderHistoryStatus { initial, loading, ready, failure }

class OrderHistoryState {
  const OrderHistoryState({
    this.status = OrderHistoryStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final OrderHistoryStatus status;
  final List<History> items;
  final String? errorMessage;

  bool get isLoading =>
      status == OrderHistoryStatus.initial ||
      status == OrderHistoryStatus.loading;

  bool get hasFailed => status == OrderHistoryStatus.failure;

  OrderHistoryState copyWith({
    OrderHistoryStatus? status,
    List<History>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OrderHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum OrderTrackStatus { initial, loading, ready, failure }

class OrderTrackState {
  const OrderTrackState({
    this.status = OrderTrackStatus.initial,
    this.order,
    this.errorMessage,
  });

  final OrderTrackStatus status;
  final Order? order;
  final String? errorMessage;

  bool get isLoading =>
      status == OrderTrackStatus.initial || status == OrderTrackStatus.loading;

  bool get hasFailed => status == OrderTrackStatus.failure;

  OrderTrackState copyWith({
    OrderTrackStatus? status,
    Order? order,
    String? errorMessage,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return OrderTrackState(
      status: status ?? this.status,
      order: clearOrder ? null : (order ?? this.order),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
