import '../../product/models/product.dart';
import '../models/home_feed.dart';

enum HomeSegment { home, category }

enum HomeStatus { initial, loading, refreshing, ready, failure }

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.feed = const HomeFeed(),
    this.segment = HomeSegment.home,
    this.selectedCategoryId,
    this.errorMessage,
  });

  const HomeState.initial() : this();

  final HomeStatus status;
  final HomeFeed feed;
  final HomeSegment segment;
  final String? selectedCategoryId;
  final String? errorMessage;

  bool get isLoading =>
      status == HomeStatus.initial || status == HomeStatus.loading;

  bool get isRefreshing => status == HomeStatus.refreshing;

  bool get hasFailed => status == HomeStatus.failure;

  bool get isReady =>
      status == HomeStatus.ready || status == HomeStatus.refreshing;

  List<Product> get visibleProducts {
    if (segment == HomeSegment.home) return feed.newArrivals;
    final selected = selectedCategoryId;
    if (selected == null || selected == 'cat-all') {
      return feed.categoryProducts;
    }
    return feed.categoryProducts
        .where((p) => p.categoryId == selected)
        .toList();
  }

  HomeState copyWith({
    HomeStatus? status,
    HomeFeed? feed,
    HomeSegment? segment,
    String? selectedCategoryId,
    String? errorMessage,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      segment: segment ?? this.segment,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
