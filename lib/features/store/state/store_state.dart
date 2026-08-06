import '../../product/models/product.dart';
import '../models/store.dart';

enum StoreDetailStatus { initial, loading, refreshing, ready, failure }

class StoreDetailState {
  const StoreDetailState({
    this.status = StoreDetailStatus.initial,
    this.store,
    this.products = const [],
    this.isFollowing = false,
    this.errorMessage,
  });

  const StoreDetailState.initial() : this();

  final StoreDetailStatus status;
  final Store? store;
  final List<Product> products;
  final bool isFollowing;
  final String? errorMessage;

  bool get isLoading =>
      status == StoreDetailStatus.initial ||
      status == StoreDetailStatus.loading;

  bool get isRefreshing => status == StoreDetailStatus.refreshing;

  bool get hasFailed => status == StoreDetailStatus.failure;

  bool get isReady =>
      status == StoreDetailStatus.ready || status == StoreDetailStatus.refreshing;

  bool get isEmpty => products.isEmpty;

  StoreDetailState copyWith({
    StoreDetailStatus? status,
    Store? store,
    List<Product>? products,
    bool? isFollowing,
    String? errorMessage,
    bool clearError = false,
    bool clearStore = false,
  }) {
    return StoreDetailState(
      status: status ?? this.status,
      store: clearStore ? null : (store ?? this.store),
      products: products ?? this.products,
      isFollowing: isFollowing ?? this.isFollowing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
