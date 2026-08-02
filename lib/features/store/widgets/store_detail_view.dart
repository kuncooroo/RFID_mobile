import 'package:flutter/material.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../product/models/product.dart';
import '../state/store_state.dart';
import 'store_header.dart';
import 'store_product_grid.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onFollowTap,
    required this.onProductTap,
  });

  final StoreDetailState state;
  final VoidCallback onRetry;
  final VoidCallback onFollowTap;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.store == null) {
      return const AppLoading.page(message: 'Loading store…');
    }

    if (state.hasFailed && state.store == null) {
      return AppErrorState(
        title: 'Could not load store',
        message: state.errorMessage ?? 'Please try again.',
        onRetry: onRetry,
      );
    }

    final store = state.store;
    if (store == null) {
      return const AppLoading.page(message: 'Loading store…');
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        StoreHeader(
          store: store,
          isFollowing: state.isFollowing,
          onFollowTap: onFollowTap,
        ),
        AppSectionHeader(title: 'Products'),
        const SizedBox(height: AppSpacing.md),
        if (state.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
            child: AppEmptyState(
              title: 'No products yet',
              message: 'This store has not listed any products.',
              icon: Icons.inventory_2_outlined,
            ),
          )
        else
          StoreProductGrid(
            products: state.products,
            onProductTap: onProductTap,
          ),
      ],
    );
  }
}
