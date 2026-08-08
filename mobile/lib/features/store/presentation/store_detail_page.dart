import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/text_styles.dart';
import '../navigation/store_navigation.dart';
import '../providers/store_providers.dart';
import '../widgets/store_detail_view.dart';

/// Store Detail screen (Figma node 1:36).
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => StoreNavigation.pop(context),
        ),
        title: Text('Store', style: AppTextStyles.headlineSmall),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => StoreNavigation.openSearch(context),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => StoreNavigation.openCart(context),
          ),
        ],
      ),
      body: StoreDetailView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onFollowTap: controller.toggleFollow,
        onMessageTap: () async {
          final store = state.store;
          if (store == null) {
            StoreNavigation.openMessages(context);
            return;
          }
          await StoreNavigation.openStoreMessage(
            context,
            ref,
            storeId: store.id,
            storeName: store.name,
            avatarUrl: store.logoUrl,
          );
        },
        onProductTap: (product) =>
            StoreNavigation.openProduct(context, product),
        onFavoriteTap: controller.toggleFavorite,
      ),
    );
  }
}
