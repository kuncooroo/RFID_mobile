import '../models/product.dart';

enum ProductDetailStatus { initial, loading, ready, failure }

class ProductDetailState {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.selectedColorId,
    this.selectedSize,
    this.quantity = 1,
    this.descriptionExpanded = false,
    this.errorMessage,
  });

  const ProductDetailState.initial() : this();

  final ProductDetailStatus status;
  final Product? product;
  final String? selectedColorId;
  final String? selectedSize;
  final int quantity;
  final bool descriptionExpanded;
  final String? errorMessage;

  bool get isLoading =>
      status == ProductDetailStatus.initial ||
      status == ProductDetailStatus.loading;

  bool get hasFailed => status == ProductDetailStatus.failure;

  bool get isReady =>
      status == ProductDetailStatus.ready || product != null;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    String? selectedColorId,
    String? selectedSize,
    int? quantity,
    bool? descriptionExpanded,
    String? errorMessage,
    bool clearError = false,
    bool clearProduct = false,
    bool clearColor = false,
    bool clearSize = false,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: clearProduct ? null : (product ?? this.product),
      selectedColorId:
          clearColor ? null : (selectedColorId ?? this.selectedColorId),
      selectedSize: clearSize ? null : (selectedSize ?? this.selectedSize),
      quantity: quantity ?? this.quantity,
      descriptionExpanded:
          descriptionExpanded ?? this.descriptionExpanded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
