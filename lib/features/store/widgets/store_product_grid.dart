import 'package:flutter/material.dart';

import '../../../shared/design_system/sizes.dart';
import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_product_card.dart';
import '../../product/models/product.dart';

class StoreProductGrid extends StatelessWidget {
  const StoreProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
            imageUrl: product.primaryImage.isEmpty ? null : product.primaryImage,
            onTap: () => onProductTap(product),
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
