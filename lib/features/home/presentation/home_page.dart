import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design_system/colors.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shell/navigation/shell_navigation.dart';
import '../../shell/providers/shell_providers.dart';
import '../../shell/widgets/shell_app_bar.dart';
import '../navigation/home_navigation.dart';
import '../providers/home_providers.dart';
import '../widgets/home_view.dart';

/// Home tab screen (shell branch root).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final badges = ref.watch(shellControllerProvider).badges;
    final userAsync = ref.watch(currentUserProvider);
    final name = userAsync.maybeWhen(
      data: (user) => user?.name.split(' ').first ?? 'there',
      orElse: () => 'there',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ShellAppBar(
        greeting: 'Hello,',
        title: name,
        unreadNotifications: badges.unreadNotifications,
        onSearch: () => HomeNavigation.openSearch(context),
        onNotifications: () => HomeNavigation.openNotifications(context),
        onCart: () => HomeNavigation.openCart(context),
      ),
      body: HomeView(
        state: state,
        onRefresh: controller.refresh,
        onRetry: controller.load,
        onSegmentChanged: controller.setSegment,
        onCategorySelected: (category) =>
            controller.selectCategory(category.id),
        onFavoriteTap: controller.toggleFavorite,
        onSearchTap: () => ShellNavigation.openSearch(context),
      ),
    );
  }
}
