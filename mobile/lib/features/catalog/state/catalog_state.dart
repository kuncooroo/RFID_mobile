import '../../product/models/product.dart';
import '../models/catalog_feed.dart';
import '../models/category.dart';

enum CatalogStatus { initial, loading, refreshing, ready, failure }

class CatalogState {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.feed = const CatalogFeed(),
    this.products = const [],
    this.selectedCategoryId,
    this.selectedCategory,
    this.errorMessage,
  });

  const CatalogState.initial() : this();

  final CatalogStatus status;
  final CatalogFeed feed;
  final List<Product> products;
  final String? selectedCategoryId;
  final Category? selectedCategory;
  final String? errorMessage;

  bool get isLoading =>
      status == CatalogStatus.initial || status == CatalogStatus.loading;

  bool get isRefreshing => status == CatalogStatus.refreshing;

  bool get hasFailed => status == CatalogStatus.failure;

  bool get isReady =>
      status == CatalogStatus.ready || status == CatalogStatus.refreshing;

  List<Category> get categories => feed.categories;

  String get title {
    final category = selectedCategory;
    if (category != null && category.name.isNotEmpty) return category.name;
    final id = selectedCategoryId;
    if (id == null || id.isEmpty || id == 'cat-all') return 'Category';
    for (final item in categories) {
      if (item.id == id) return item.name;
    }
    return 'Category';
  }

  CatalogState copyWith({
    CatalogStatus? status,
    CatalogFeed? feed,
    List<Product>? products,
    String? selectedCategoryId,
    Category? selectedCategory,
    String? errorMessage,
    bool clearSelectedCategory = false,
    bool clearError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      products: products ?? this.products,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
