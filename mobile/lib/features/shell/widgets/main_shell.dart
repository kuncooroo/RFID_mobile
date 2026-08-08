import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/design_system/app_icons.dart';
import '../../../shared/design_system/colors.dart';
import '../../../shared/design_system/sizes.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';
import '../../../shared/widgets/app_icon.dart';
import '../models/shell_tab.dart';
import '../providers/shell_providers.dart';

/// Main app shell with GoRouter [StatefulNavigationShell] + docked RFID FAB.
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

  void _openRfidScan() {
    context.push(AppRoutes.rfidScan);
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
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag_rounded,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _RfidScanFab(onPressed: _openRfidScan),
      bottomNavigationBar: AppBottomNavigation(
        items: items,
        currentIndex: current.branchIndex,
        hasCenterFab: true,
        onTap: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _RfidScanFab extends StatelessWidget {
  const _RfidScanFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.fabSize,
      height: AppSizes.fabSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Scan RFID Member',
        elevation: 6,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.sensors_rounded, size: 28),
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
