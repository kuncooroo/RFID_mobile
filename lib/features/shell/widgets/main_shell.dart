import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/app_icons.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/shell_tab.dart';
import '../providers/shell_providers.dart';

/// Main app shell with GoRouter [StatefulNavigationShell] + bottom navigation.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(shellControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final badges = ref.watch(shellControllerProvider).badges;
    final current = ShellTab.fromIndex(widget.navigationShell.currentIndex);

    final items = <AppBottomNavItem>[
      const AppBottomNavItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      AppBottomNavItem(
        label: 'My Order',
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping_rounded,
        badgeCount: badges.activeOrders > 0 ? badges.activeOrders : null,
      ),
      const AppBottomNavItem(
        label: 'Favorite',
        icon: Icons.favorite_border_rounded,
        activeIcon: Icons.favorite_rounded,
      ),
      const AppBottomNavItem(
        label: 'My Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        items: items,
        currentIndex: current.branchIndex,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Optional SVG-aware bottom item builder for when icon assets are bundled.
abstract final class ShellBottomNavIcons {
  static Widget icon(ShellTab tab, {required bool selected, Color? color}) {
    final path = switch (tab) {
      ShellTab.home => selected ? AppIcons.homeFilled : AppIcons.home,
      ShellTab.orders => selected ? AppIcons.orderFilled : AppIcons.order,
      ShellTab.favorites =>
        selected ? AppIcons.favoriteFilled : AppIcons.favorite,
      ShellTab.profile => selected ? AppIcons.profileFilled : AppIcons.profile,
    };
    return AppIcon.asset(path, color: color);
  }
}
