import 'package:flutter/material.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/radius.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/product.dart';
import '../navigation/product_navigation.dart';
import '../state/product_detail_state.dart';
import 'product_gallery.dart';
import 'product_info_section.dart';
import 'product_reviews_section.dart';

/// Product Detail scroll body — gallery hero + overlapping content sheet.
class ProductDetailView extends StatelessWidget {
  const ProductDetailView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onQuantityChanged,
    required this.onReadMoreTap,
    this.storeLogoUrl,
    this.storeVerified = false,
  });

  final ProductDetailState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onColorSelected;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onReadMoreTap;
  final String? storeLogoUrl;
  final bool storeVerified;

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
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ProductGallery(imageUrls: images),
              Positioned(
                left: 0,
                right: 0,
                bottom: -1,
                child: Container(
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.detailSheet,
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppColors.background,
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
              storeLogoUrl: storeLogoUrl,
              storeVerified: storeVerified,
              onStoreTap: product.storeId != null
                  ? () => ProductNavigation.openStore(context, product.storeId!)
                  : null,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ColoredBox(
            color: AppColors.background,
            child: ProductReviewsSection(reviews: state.reviews),
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
