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

/// Product Detail screen (Figma nodes 1:37 Detail / 1:40 Detail v2).
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
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => ProductNavigation.pop(context),
        ),
        title: Text('Product Detail', style: AppTextStyles.headlineSmall),
        centerTitle: false,
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
            tooltip: 'Cart',
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
        storeLogoUrl: state.storeLogoUrl,
        storeVerified: state.storeVerified,
      ),
      bottomNavigationBar: product == null
          ? null
          : ProductStickyBar(
              product: product,
              isLoading: state.isAddingToCart,
              onAddToCart: () => _addToCart(),
            ),
    );
  }

  Future<void> _addToCart() async {
    final controller = ref.read(
      productDetailControllerProvider(widget.productId).notifier,
    );
    final state = ref.read(productDetailControllerProvider(widget.productId));
    final product = state.product;
    if (product == null || state.isAddingToCart) return;

    if (product.sizes.isNotEmpty &&
        (state.selectedSize == null || state.selectedSize!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size')),
      );
      return;
    }

    String? colorName;
    if (state.selectedColorId != null) {
      for (final color in product.colors) {
        if (color.id == state.selectedColorId) {
          colorName = color.name;
          break;
        }
      }
    }

    controller.setAddingToCart(true);
    try {
      await ref.read(cartControllerProvider.notifier).addProduct(
            product: product,
            quantity: state.quantity,
            colorName: colorName,
            size: state.selectedSize,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => ProductNavigation.openCart(context),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add to cart: $error')),
      );
    } finally {
      controller.setAddingToCart(false);
    }
  }
}
