import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../../../shared/widgets/app_favorite_button.dart';
import '../../cart/providers/cart_providers.dart';
import '../navigation/product_navigation.dart';
import '../providers/product_providers.dart';
import '../widgets/product_detail_view.dart';
import '../widgets/product_sticky_bar.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(productDetailControllerProvider(widget.productId).notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailControllerProvider(widget.productId));
    final controller = ref.read(
      productDetailControllerProvider(widget.productId).notifier,
    );
    final product = state.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => ProductNavigation.pop(context),
        ),
        title: Text('Product Detail', style: AppTextStyles.headlineSmall),
        actions: [
          if (product != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AppFavoriteButton(
                isFavorite: product.isFavorite,
                onPressed: controller.toggleFavorite,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => ProductNavigation.openCart(context),
          ),
        ],
      ),
      body: ProductDetailView(
        state: state,
        onRetry: controller.load,
        onColorSelected: controller.selectColor,
        onSizeSelected: controller.selectSize,
        onQuantityChanged: controller.setQuantity,
        onReadMoreTap: controller.toggleDescriptionExpanded,
      ),
      bottomNavigationBar: product == null
          ? null
          : ProductStickyBar(
              product: product,
              onAddToCart: () => _addToCart(),
            ),
    );
  }

  Future<void> _addToCart() async {
    final state = ref.read(productDetailControllerProvider(widget.productId));
    final product = state.product;
    if (product == null) return;

    String? colorName;
    if (state.selectedColorId != null) {
      for (final color in product.colors) {
        if (color.id == state.selectedColorId) {
          colorName = color.name;
          break;
        }
      }
    }

    await ref.read(cartControllerProvider.notifier).addProduct(
          product: product,
          quantity: state.quantity,
          colorName: colorName,
          size: state.selectedSize,
        );
    if (!mounted) return;
    ProductNavigation.openCart(context);
  }
}
