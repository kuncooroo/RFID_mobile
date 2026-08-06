import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../shell/providers/shell_providers.dart';
import '../../shell/widgets/shell_app_bar.dart';
import '../navigation/favorites_navigation.dart';
import '../providers/favorites_providers.dart';
import '../widgets/favorites_view.dart';

/// Favorite tab screen (shell branch root).
class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(favoritesControllerProvider.notifier).load();
    });
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showAppDialog(
      context: context,
      title: 'Clear favorites?',
      message: 'Remove all saved products from your favorites list.',
      confirmLabel: 'Clear all',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(favoritesControllerProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesControllerProvider);
    final controller = ref.read(favoritesControllerProvider.notifier);
    final badges = ref.watch(
      shellControllerProvider.select((s) => s.badges),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShellAppBar(
        title: 'Favorite',
        unreadNotifications: badges.unreadNotifications,
        onNotifications: () => FavoritesNavigation.openNotifications(context),
        onCart: () => FavoritesNavigation.openCart(context),
      ),
      body: FavoritesView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onRemove: controller.remove,
        onClearAll: _confirmClearAll,
      ),
    );
  }
}
