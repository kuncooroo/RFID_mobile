import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../product/models/product.dart';
import '../repository/catalog_repository.dart';
import '../repository/mock_catalog_repository.dart';
import '../state/catalog_state.dart';
import '../../../src/network/api_client.dart';
import '../repository/remote_catalog_repository.dart';

/// Pass `--dart-define=USE_MOCK_CATALOG=true` to force the mock repository.
const bool kUseMockCatalogRepository = bool.fromEnvironment(
  'USE_MOCK_CATALOG',
  defaultValue: false,
);

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  if (kUseMockCatalogRepository) {
    return MockCatalogRepository();
  }
  return RemoteCatalogRepository(api: ref.watch(apiClientProvider));
});

final catalogControllerProvider =
    NotifierProvider<CatalogController, CatalogState>(CatalogController.new);

class CatalogController extends Notifier<CatalogState> {
  @override
  CatalogState build() => const CatalogState.initial();

  Future<void> loadCategories() async {
    if (state.status == CatalogStatus.loading && state.feed.isEmpty) return;
    state = state.copyWith(status: CatalogStatus.loading, clearError: true);
    try {
      final feed = await ref.read(catalogRepositoryProvider).fetchCatalog();
      state = state.copyWith(status: CatalogStatus.ready, feed: feed);
    } catch (error) {
      state = state.copyWith(
        status: CatalogStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshCategories() async {
    state = state.copyWith(status: CatalogStatus.refreshing, clearError: true);
    try {
      final feed = await ref.read(catalogRepositoryProvider).fetchCatalog();
      state = state.copyWith(status: CatalogStatus.ready, feed: feed);
    } catch (error) {
      state = state.copyWith(
        status: CatalogStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadProducts({String? categoryId}) async {
    final hasCategory = categoryId != null && categoryId.isNotEmpty;
    state = state.copyWith(
      status: CatalogStatus.loading,
      selectedCategoryId: categoryId,
      clearError: true,
      clearSelectedCategory: !hasCategory,
    );

    try {
      final repository = ref.read(catalogRepositoryProvider);
      final products = await repository.fetchProducts(categoryId: categoryId);
      final category =
          hasCategory ? await repository.fetchCategory(categoryId) : null;

      state = state.copyWith(
        status: CatalogStatus.ready,
        products: products,
        selectedCategoryId: categoryId,
        selectedCategory: category,
        clearSelectedCategory: !hasCategory,
      );
    } catch (error) {
      state = state.copyWith(
        status: CatalogStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshProducts() async {
    final categoryId = state.selectedCategoryId;
    state = state.copyWith(status: CatalogStatus.refreshing, clearError: true);
    try {
      final products = await ref
          .read(catalogRepositoryProvider)
          .fetchProducts(categoryId: categoryId);
      state = state.copyWith(status: CatalogStatus.ready, products: products);
    } catch (error) {
      state = state.copyWith(
        status: CatalogStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> toggleFavorite(Product product) async {
    await ref.read(catalogRepositoryProvider).toggleFavorite(product.id);
    state = state.copyWith(
      products: state.products
          .map(
            (p) =>
                p.id == product.id ? p.copyWith(isFavorite: !p.isFavorite) : p,
          )
          .toList(),
    );
  }
}
