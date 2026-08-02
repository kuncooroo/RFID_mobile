import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/local_product_repository.dart';
import '../repository/mock_product_repository.dart';
import '../repository/product_repository.dart';
import '../state/product_detail_state.dart';

/// Pass `--dart-define=USE_MOCK_PRODUCT=true` to force the mock repository.
const bool kUseMockProductRepository = bool.fromEnvironment(
  'USE_MOCK_PRODUCT',
  defaultValue: false,
);

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  if (kUseMockProductRepository) {
    return MockProductRepository();
  }
  return LocalProductRepository();
});

final productDetailControllerProvider =
    NotifierProvider.family<ProductDetailController, ProductDetailState, String>(
      ProductDetailController.new,
    );

class ProductDetailController extends Notifier<ProductDetailState> {
  ProductDetailController(this.productId);

  final String productId;

  @override
  ProductDetailState build() => const ProductDetailState.initial();

  Future<void> load() async {
    if (state.status == ProductDetailStatus.loading) return;
    state = state.copyWith(
      status: ProductDetailStatus.loading,
      clearError: true,
    );
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .fetchProduct(productId);
      final defaultColorId = product.colors.isNotEmpty
          ? product.colors.first.id
          : null;
      final defaultSize = product.sizes.isNotEmpty ? product.sizes.first : null;
      state = state.copyWith(
        status: ProductDetailStatus.ready,
        product: product,
        selectedColorId: defaultColorId,
        selectedSize: defaultSize,
        quantity: 1,
        descriptionExpanded: false,
      );
    } catch (error) {
      state = state.copyWith(
        status: ProductDetailStatus.failure,
        errorMessage: error.toString(),
        clearProduct: true,
      );
    }
  }

  void selectColor(String colorId) {
    if (state.selectedColorId == colorId) return;
    state = state.copyWith(selectedColorId: colorId);
  }

  void selectSize(String size) {
    if (state.selectedSize == size) return;
    state = state.copyWith(selectedSize: size);
  }

  void setQuantity(int quantity) {
    final product = state.product;
    if (product == null) return;
    final max = product.stock > 0 ? product.stock : 99;
    final clamped = quantity.clamp(1, max);
    if (clamped == state.quantity) return;
    state = state.copyWith(quantity: clamped);
  }

  void toggleDescriptionExpanded() {
    state = state.copyWith(descriptionExpanded: !state.descriptionExpanded);
  }

  Future<void> toggleFavorite() async {
    final product = state.product;
    if (product == null) return;

    final nextFavorite = !product.isFavorite;
    state = state.copyWith(
      product: product.copyWith(isFavorite: nextFavorite),
    );

    try {
      await ref.read(productRepositoryProvider).toggleFavorite(product.id);
    } catch (error) {
      state = state.copyWith(
        product: product,
        errorMessage: error.toString(),
      );
    }
  }
}
