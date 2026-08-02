import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/store_navigation.dart';
import '../providers/store_providers.dart';
import '../widgets/store_detail_view.dart';

class StoreDetailPage extends ConsumerStatefulWidget {
  const StoreDetailPage({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends ConsumerState<StoreDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(storeDetailControllerProvider(widget.storeId).notifier)
          .load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storeDetailControllerProvider(widget.storeId));
    final controller = ref.read(
      storeDetailControllerProvider(widget.storeId).notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => StoreNavigation.pop(context),
        ),
        title: Text(
          state.store?.name ?? 'Store',
          style: AppTextStyles.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => StoreNavigation.openCart(context),
          ),
        ],
      ),
      body: StoreDetailView(
        state: state,
        onRetry: controller.load,
        onFollowTap: controller.toggleFollow,
        onProductTap: (product) =>
            StoreNavigation.openProduct(context, product),
      ),
    );
  }
}
