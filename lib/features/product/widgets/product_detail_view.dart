import 'package:flutter/material.dart';

import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/product.dart';
import '../navigation/product_navigation.dart';
import '../state/product_detail_state.dart';
import 'product_gallery.dart';
import 'product_info_section.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onQuantityChanged,
    required this.onReadMoreTap,
  });

  final ProductDetailState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onReadMoreTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.product == null) {
      return const AppLoading.page(message: 'Loading product…');
    }

    if (state.hasFailed && state.product == null) {
      return AppErrorState(
        title: 'Could not load product',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    final product = state.product;
    if (product == null) {
      return const AppLoading.page(message: 'Loading product…');
    }

    final images = _galleryImages(product);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: ProductGallery(imageUrls: images)),
        SliverToBoxAdapter(
          child: ProductInfoSection(
            product: product,
            selectedColorId: state.selectedColorId,
            selectedSize: state.selectedSize,
            quantity: state.quantity,
            descriptionExpanded: state.descriptionExpanded,
            onColorSelected: onColorSelected,
            onSizeSelected: onSizeSelected,
            onQuantityChanged: onQuantityChanged,
            onReadMoreTap: onReadMoreTap,
            onStoreTap: product.storeId != null
                ? () => ProductNavigation.openStore(context, product.storeId!)
                : null,
          ),
        ),
      ],
    );
  }

  List<String> _galleryImages(Product product) {
    if (product.images.isNotEmpty) return product.images;
    if (product.primaryImage.isNotEmpty) return [product.primaryImage];
    return const [];
  }
}
