import 'package:flutter/material.dart';

import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../product/models/product.dart';

class HomeProductGrid extends StatelessWidget {
  const HomeProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onFavoriteTap,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onFavoriteTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppSizes.productGridCrossAxisCount,
          mainAxisSpacing: AppSpacing.grid,
          crossAxisSpacing: AppSpacing.grid,
          childAspectRatio: AppSizes.productGridAspectRatio,
        ),
        itemBuilder: (context, index) {
          final product = products[index];
          return AppProductCard(
            name: product.name,
            brand: product.brand,
            priceLabel: _priceLabel(product),
            imageUrl: product.primaryImage.isEmpty
                ? null
                : product.primaryImage,
            isFavorite: product.isFavorite,
            onTap: () => onProductTap(product),
            onFavoriteTap: () => onFavoriteTap(product),
          );
        },
      ),
    );
  }

  String _priceLabel(Product product) {
    final currency = product.currency == 'USD' ? '\$' : '${product.currency} ';
    return '$currency${product.displayPrice.toStringAsFixed(0)}';
  }
}
