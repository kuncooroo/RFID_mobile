import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/local_orders_repository.dart';
import '../repository/mock_orders_repository.dart';
import '../repository/orders_repository.dart';
import '../state/orders_state.dart';

/// Pass `--dart-define=USE_MOCK_ORDERS=true` to force the mock repository.
const bool kUseMockOrdersRepository = bool.fromEnvironment(
  'USE_MOCK_ORDERS',
  defaultValue: false,
);

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  if (kUseMockOrdersRepository) {
    return MockOrdersRepository();
  }
  return LocalOrdersRepository();
});

final ordersControllerProvider =
    NotifierProvider<OrdersController, OrdersState>(OrdersController.new);

final orderHistoryControllerProvider =
    NotifierProvider<OrderHistoryController, OrderHistoryState>(
      OrderHistoryController.new,
    );

final orderTrackControllerProvider =
    NotifierProvider.family<OrderTrackController, OrderTrackState, String>(
      OrderTrackController.new,
    );

class OrdersController extends Notifier<OrdersState> {
  @override
  OrdersState build() => const OrdersState.initial();

  Future<void> load() async {
    if (state.status == OrdersStatus.loading) return;
    state = state.copyWith(status: OrdersStatus.loading, clearError: true);
    await _fetch(status: OrdersStatus.ready);
  }

  Future<void> refresh() async {
    state = state.copyWith(status: OrdersStatus.refreshing, clearError: true);
    await _fetch(status: OrdersStatus.ready);
  }

  Future<void> _fetch({required OrdersStatus status}) async {
    try {
      final feed = await ref.read(ordersRepositoryProvider).fetchOrdersFeed();
      state = state.copyWith(status: status, feed: feed);
    } catch (error) {
      state = state.copyWith(
        status: OrdersStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  void setSegment(OrdersSegment segment) {
    if (state.segment == segment) return;
    state = state.copyWith(segment: segment);
  }
}

class OrderHistoryController extends Notifier<OrderHistoryState> {
  @override
  OrderHistoryState build() => const OrderHistoryState();

  Future<void> load() async {
    state = state.copyWith(
      status: OrderHistoryStatus.loading,
      clearError: true,
    );
    try {
      final items = await ref
          .read(ordersRepositoryProvider)
          .fetchOrderHistory();
      state = state.copyWith(status: OrderHistoryStatus.ready, items: items);
    } catch (error) {
      state = state.copyWith(
        status: OrderHistoryStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }
}

class OrderTrackController extends Notifier<OrderTrackState> {
  OrderTrackController(this.orderId);

  final String orderId;

  @override
  OrderTrackState build() => const OrderTrackState();

  Future<void> load() async {
    state = state.copyWith(status: OrderTrackStatus.loading, clearError: true);
    try {
      final order = await ref
          .read(ordersRepositoryProvider)
          .fetchOrderById(orderId);
      state = state.copyWith(status: OrderTrackStatus.ready, order: order);
    } catch (error) {
      state = state.copyWith(
        status: OrderTrackStatus.failure,
        errorMessage: error.toString(),
        clearOrder: true,
      );
    }
  }
}
